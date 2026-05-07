/*
    Naive n^2 N-body simulation.
    Thread-based parallel version using CyclicBarrier.

    (c) Michael L. Scott, 2025
    Based on code originally developed in 2008.
    For use by students in CSC 2/454 at the University of Rochester,
    during the fall 2025 term.  All other use requires written
    permission of the author.
*/

import java.awt.*;
import java.awt.event.*;
import java.io.*;
import javax.swing.*;
import java.util.*;
import java.lang.*;
import java.util.concurrent.*;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.cos;

public class NbodyThreads {
    private static int nStars = 500;
    private static int width = 800;
    private static long seed = 0;
    private static double gravityBase = 1e-15;
    private static double gravity = 100;
    private static double velocityBase = 1e-6;
    private static double velocity = 100;
    private static int displayStep = 100;
    private static int stepLimit = 0;
    private static int nThreads = Runtime.getRuntime().availableProcessors();

    private static void usage() {
        System.err.println("Usage: java NbodyThreads [-n stars] [-w pixels]"
                                          + " [-s seed] [-g gravity]");
        System.err.println("                  [-v velocity] [-x displaystep]"
                                          + " [-l steplimit] [-t threads]");
        System.err.println("Defaults: n=" + nStars
                                  + " w=" + width
                                  + " s=" + seed
                                  + " g=" + gravity
                                  + " v=" + velocity
                                  + " x=" + displayStep
                                  + " l=" + stepLimit
                                  + " t=" + nThreads);
        System.exit(-1);
    }

    private static void parseArgs(String[] args) {
        for (int i = 0; i < args.length; i++) {
            String option = args[i];
            if (++i < args.length) {
                int arg = Integer.valueOf(args[i]);
                if (arg <= 0) {
                    System.err.println("args must be positive");
                    usage();
                }
                if (option.contentEquals("-n")) {
                    nStars = arg;
                } else if (option.contentEquals("-w")) {
                    width = arg;
                } else if (option.contentEquals("-s")) {
                    seed = arg;
                } else if (option.contentEquals("-g")) {
                    gravity = arg;
                } else if (option.contentEquals("-v")) {
                    velocity = arg;
                } else if (option.contentEquals("-x")) {
                    displayStep = arg;
                } else if (option.contentEquals("-l")) {
                    stepLimit = arg;
                } else if (option.contentEquals("-t")) {
                    nThreads = arg;
                } else usage();
            } else usage();
        }
        gravity *= gravityBase;
        velocity *= velocityBase;
    }

    public static void main(String[] args) {
        parseArgs(args);
        JFrame f = new JFrame("NbodyThreads");
        f.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                System.exit(0);
            }
        });
        NbodyThreads me = new NbodyThreads();
        new UI(nStars, width, seed, gravity,
               velocity, displayStep, stepLimit, nThreads, f);
        f.pack();
        f.setVisible(true);
    }
}

// Worker thread for parallel computation
class ComputeWorker extends Thread {
    private final Space space;
    private final int id;
    private final int nThreads;
    private final CyclicBarrier barrier;
    private volatile boolean shouldStop = false;

    public void shutdown() {
        shouldStop = true;
    }

    public void run() {
        try {
            while (!shouldStop) {
                barrier.await();  // Wait for all threads to start step
                if (shouldStop) break;
                space.doStepPart(id, nThreads);
                barrier.await();  // Wait for all threads to finish step
            }
        } catch (InterruptedException | BrokenBarrierException e) {
            // Thread interrupted, exit gracefully
        }
    }

    public ComputeWorker(Space S, int myId, int threads, CyclicBarrier b) {
        space = S;
        id = myId;
        nThreads = threads;
        barrier = b;
    }
}

// The Worker is the main coordination thread
class Worker extends Thread {
    private final Space space;

    public void run() {
        space.simulate();
    }

    public Worker(Space S) {
        space = S;
    }
}

class Space extends JPanel {
    private final int dotsize = 2;
    private final int border = dotsize;

    private final int nStars;
    private final int width;
    private double extreme;
    private final double gravity;
    private final double velocity;
    private final int displayStep;
    private final int stepLimit;
    private final int nThreads;
    private final UI parent;
    private final Stats stats;

    private final Random prn;
    private Star[] stars = null;
    private Star[] otherStars = null;

    // Thread management
    private CyclicBarrier barrier;
    private ComputeWorker[] workers;

    private int Pixel(double x) {
        final double xx = x;
        if (x > extreme) {
            x = extreme;
        } else if (x < -extreme) {
            x = -extreme;
        }
        if (abs(xx) > extreme) {
            extreme = abs(xx);
        }
        return (int) ((x + extreme) / extreme / 2.0 * (double) width + 0.5)
               + border;
    }

    private class Star {
        double xPos;
        double yPos;
        double xVel;
        double yVel;

        public void render(Graphics g) {
            g.setColor(Color.yellow);
            g.fillOval(Pixel(xPos)-dotsize/2,
                       Pixel(yPos)-dotsize/2,
                       dotsize, dotsize);
        }

        public Star(double X, double Y, double xv, double yv) {
            xPos = X;  yPos = Y;
            xVel = xv;  yVel = yv;
        }
        public Star() {
            xPos = yPos = xVel = yVel = 0.0;
        }
    }

    public void reset(long seed) {
        prn.setSeed(seed);
        extreme = 1.0;
        for (int i = 0; i < nStars; i++) {
            final double lrho = prn.nextDouble();
            final double ltheta = prn.nextDouble() * Math.PI * 2.0;
            final double vrho = prn.nextDouble() * velocity;
            final double vtheta = prn.nextDouble() * Math.PI * 2.0;
            stars[i] = new Star(lrho * cos(ltheta), lrho * sin(ltheta),
                vrho * cos(vtheta), vrho * sin(vtheta));
            otherStars[i] = new Star();
        }
        repaint();
    }

    private volatile boolean running = true;
    private volatile boolean killed = false;

    public synchronized void start() {
        running = true;
        killed = false;
        // Create barrier and worker threads
        barrier = new CyclicBarrier(nThreads + 1);  // +1 for main simulation thread
        workers = new ComputeWorker[nThreads];
        for (int i = 0; i < nThreads; i++) {
            workers[i] = new ComputeWorker(this, i, nThreads, barrier);
            workers[i].start();
        }
    }

    public synchronized void stop() {
        running = false;
        killed = true;
        // Shutdown worker threads
        if (workers != null) {
            for (int i = 0; i < nThreads; i++) {
                if (workers[i] != null) {
                    workers[i].shutdown();
                }
            }
            try {
                barrier.await();  // Release threads from barrier
            } catch (Exception e) {}
        }
        notify();
    }

    public synchronized void toggle() {
        running = !running;
        if (running) notify();
    }

    // Compute forces and update positions for a subset of stars
    // Better load balancing: distribute remainder evenly
    public void doStepPart(int threadId, int numThreads) {
        int starsPerThread = nStars / numThreads;
        int remainder = nStars % numThreads;

        // Threads with id < remainder get one extra star
        int startIdx, endIdx;
        if (threadId < remainder) {
            startIdx = threadId * (starsPerThread + 1);
            endIdx = startIdx + starsPerThread + 1;
        } else {
            startIdx = threadId * starsPerThread + remainder;
            endIdx = startIdx + starsPerThread;
        }

        for (int i = startIdx; i < endIdx; i++) {
            Star p = stars[i];
            double xForce = 0;
            double yForce = 0;
            // Cache position to avoid repeated array access
            final double myX = p.xPos;
            final double myY = p.yPos;

            for (int j = 0; j < nStars; j++) {
                if (i != j) {
                    Star other = stars[j];
                    final double dX = other.xPos - myX;
                    final double dY = other.yPos - myY;
                    final double rSquared = dX * dX + dY * dY;
                    final double r = Math.sqrt(rSquared);
                    final double rCubed = rSquared * r;
                    xForce += dX/rCubed;
                    yForce += dY/rCubed;
                }
            }
            xForce *= gravity;
            yForce *= gravity;
            Star q = otherStars[i];
            q.xPos = p.xPos + p.xVel + xForce/2.0;
            q.yPos = p.yPos + p.yVel + yForce/2.0;
            q.xVel = p.xVel + xForce;
            q.yVel = p.yVel + yForce;
        }
    }

    public void simulate() {
        int i = 0;
        while (!killed) {
            if (stepLimit != 0 && i >= stepLimit) {
                repaint();
                stats.revise(i, (int) (extreme + 0.5));
                parent.pause();
                return;
            }

            try {
                barrier.await();  // Signal workers to start
                barrier.await();  // Wait for workers to finish
            } catch (InterruptedException | BrokenBarrierException e) {
                if (killed) break;
            }

            // Swap arrays
            Star[] tmp = stars;
            stars = otherStars;
            otherStars = tmp;

            if (++i % displayStep == 0) {
                repaint();
                stats.revise(i, (int) extreme);
            }
            if (!running && !killed && i % displayStep == 0) {
                synchronized(this) {
                    while (!running && !killed) {
                        try {
                            wait();
                        } catch (InterruptedException e) {}
                    }
                }
            }
        }
    }

    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        setBackground(Color.black);
        for (int i = 0; i < nStars; i++) {
            stars[i].render(g);
        }
    }

    public Space(int B, int W, long S, double G,
                 double V, int X, int L, int T, UI P, Stats U) {
        nStars = B;
        width = W;
        gravity = G;
        velocity = V;
        displayStep = X;
        stepLimit = L;
        nThreads = T;
        parent = P;
        stats = U;
        extreme = 1.0;

        setPreferredSize(new Dimension(width+(border*2)+1, width+(border*2)+1));

        stars = new Star[nStars];
        otherStars = new Star[nStars];

        prn = new Random();
        reset(S);
    }
}

class Stats extends JPanel {
    private final JLabel timeL = new JLabel("time: 0   ");
    private final JLabel seedL = new JLabel("seed: 0   ");
    private final JLabel stepL = new JLabel("step: 0   ");
    private final JLabel scaleL = new JLabel("scale: 1   ");
    private long startTime = 0;
    private long elapsedTime = 0;
    private boolean stopped = false;

    public synchronized void startClock() {
        startTime = System.currentTimeMillis();
        stopped = false;
    }

    public synchronized void stopClock() {
        stopped = true;
    }

    public synchronized void revise(int step, int scale) {
        final long inc = System.currentTimeMillis() - startTime;
        final long t = inc + elapsedTime;
        SwingUtilities.invokeLater(() -> {
            stepL.setText("step: " + step + "  ");
            timeL.setText("time: " + t/1000 + "." + t%1000/100 + "  ");
            scaleL.setText("scale: " + scale + "  ");
        });
        if (stopped) {
            elapsedTime += inc;
        }
        repaint();
    }

    public synchronized void reset(long seed) {
        elapsedTime = 0;
        SwingUtilities.invokeLater(() -> {
            seedL.setText("seed: " + seed + "  ");
            stepL.setText("step: 0  ");
            timeL.setText("time: 0  ");
            scaleL.setText("scale: 1  ");
        });
        repaint();
    }

    public Stats(int ts, long seed) {
        add(seedL);
        add(stepL);
        add(timeL);
        add(scaleL);
        reset(seed);
    }
}

class UI extends JPanel {
    private final Space space;

    private final JRootPane root;
    private final int externalBorder = 6;

    private enum Status {STOPPED, RUNNING, PAUSED};
    private final JButton runButton;

    private Status state = Status.STOPPED;
    private long seed;

    private Stats stats = null;

    public void pause() {
        root.setDefaultButton(runButton);
    }

    public UI(int B, int W, long S, double G, double V, int X, int L, int T,
              RootPaneContainer pane) {
        final UI ui = this;
        seed = S;
        stats = new Stats(X, seed);
        space = new Space(B, W, S, G, V, X, L, T, this, stats);

        final JPanel buttons = new JPanel();

        runButton = new JButton("Run");
        final JButton pauseButton = new JButton("Pause");
        final JButton resetButton = new JButton("Reset");
        final JButton randomizeButton = new JButton("Randomize");
        final JButton quitButton = new JButton("Quit");

        final Collection<Worker> workers = new LinkedList<Worker>();

        runButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (state == Status.STOPPED) {
                    state = Status.RUNNING;
                    root.setDefaultButton(pauseButton);
                    Worker w = new Worker(space);
                    stats.startClock();
                    space.start();
                    w.start();
                    workers.add(w);
                } else if (state == Status.PAUSED) {
                    state = Status.RUNNING;
                    root.setDefaultButton(pauseButton);
                    stats.startClock();
                    space.toggle();
                }
            }
        });
        pauseButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                if (state == Status.RUNNING) {
                    stats.stopClock();
                    state = Status.PAUSED;
                    root.setDefaultButton(runButton);
                    space.toggle();
                }
            }
        });
        resetButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                state = Status.STOPPED;
                space.stop();
                for (Worker w : workers) {
                    try {
                        w.join();
                    } catch (InterruptedException f) {}
                }
                workers.clear();
                root.setDefaultButton(runButton);
                space.reset(seed);
                stats.reset(seed);
            }
        });
        randomizeButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                seed++;
                state = Status.STOPPED;
                space.stop();
                for (Worker w : workers) {
                    try {
                        w.join();
                    } catch (InterruptedException f) {}
                }
                workers.clear();
                root.setDefaultButton(runButton);
                space.reset(seed);
                stats.reset(seed);
            }
        });
        quitButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                System.exit(0);
            }
        });

        buttons.setLayout(new FlowLayout());
        buttons.add(runButton);
        buttons.add(pauseButton);
        buttons.add(resetButton);
        buttons.add(randomizeButton);
        buttons.add(quitButton);

        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setBorder(BorderFactory.createEmptyBorder(
            externalBorder, externalBorder, externalBorder, externalBorder));
        add(space);
        add(buttons);
        add(stats);

        pane.getContentPane().add(this);
        root = getRootPane();
        root.setDefaultButton(runButton);
    }
}
