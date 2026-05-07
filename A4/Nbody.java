/*
    Naive n^2 N-body simulation.
    Currently single-threaded.

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
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.cos;

// The root class.  Contains main, which creates the UI, which in turn
// creates the Space and Stats objects, and also contains handlers for
// buttons.
//
public class Nbody {
    private static int nStars = 500;    // number of stars
    private static int width = 800;     // window: pixels on a side
    private static long seed = 0;
    private static double gravityBase = 1e-15;
    private static double gravity = 100;
        // Gravitational constant, in no particular units
        // (makes the default size simulation run at a slow but
        // noticeable rate).  If you specify a different gravity
        // value, it functions as a multiple of gravityBase.
    private static double velocityBase = 1e-6;
    private static double velocity = 100;
        // Similarly, velocityBase is chosen for reasonable default
        // behavior.  Command-line override is a multiple of base.
    private static int displayStep = 100;
        // How often to update the display.
    private static int stepLimit = 0;
        // Zero means run indefinitely; positive command-line arg causes
        // simulation to stop after that many steps.

    private static void usage() {
        System.err.println("Usage: java Nbody [-n stars] [-w pixels]"
                                          + " [-s seed] [-g gravity]");
        System.err.println("                  [-v velocity] [-x displaystep]"
                                          + " [-l steplimit]");
        System.err.println("Defaults: n=" + nStars
                                  + " w=" + width
                                  + " s=" + seed
                                  + " g=" + gravity
                                  + " v=" + velocity
                                  + " x=" + displayStep
                                  + " l=" + stepLimit);
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
                } else usage();
            } else usage();
        }
        gravity *= gravityBase;
        velocity *= velocityBase;
    }

    public static void main(String[] args) {
        parseArgs(args);
        JFrame f = new JFrame("Nbody");
        f.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                System.exit(0);
            }
        });
        Nbody me = new Nbody();
        new UI(nStars, width, seed, gravity,
               velocity, displayStep, stepLimit, f);
        f.pack();
        f.setVisible(true);
    }
}

// The Worker is the thread that does the actual work of the simulation
// (by calling Space.simulate)
//
class Worker extends Thread {
    private final Space space;

    // Thread.run() is never invoked directly by user code.  Rather, it
    // is called by the Java runtime when user code calls Thread.start().
    //
    public void run() {
        space.simulate();
    }

    // Constructor
    //
    public Worker(Space S) {
        space = S;
    }
}

// The Space is the Nbody world, containing all the stars.
// It embeds all knowledge about how to display stars graphically.
//
class Space extends JPanel {
    private final int dotsize = 2;
    private final int border = dotsize;

    // following fields are set by constructor:
    private final int nStars;   // number of stars
    private final int width;    // canvas dimensions
    private double extreme;
        // Largest absolute value of a coordinate.
        // Stars tend to fly apart.  As they do, the viewer will
        // scale (pan out) and continue to show them all.
    private final double gravity;
    private final double velocity;
    private final int displayStep;
    private final int stepLimit;
    private final UI parent;
    private final Stats stats;

    private final Random prn;     // pseudo-random number generator
    private Star[] stars = null;
    private Star[] otherStars = null;

    // This routine figures out where to render (one coorginate of) the
    // dot for a star, given the size of the canvas.  If a star has
    // escaped the visible field, it is temporarily rendered (for this
    // generation) at the last pixel.  Space.extreme is updated, however,
    // so scaling will change in the next generation.  If you implement
    // non-uniform mass for stars, you might want to make the size or
    // color dependent on mass.
    //
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

        // Render self on the Space canvas.
        //
        public void render(Graphics g) {
            g.setColor(Color.yellow);
            g.fillOval(Pixel(xPos)-dotsize/2,
                       Pixel(yPos)-dotsize/2,
                       dotsize, dotsize);
        }

        // Constructor
        //
        public Star(double X, double Y, double xv, double yv) {
            xPos = X;  yPos = Y;
            xVel = xv;  yVel = yv;
        }
        public Star() {
            xPos = yPos = xVel = yVel = 0.0;
        }
    }

    // Called by the UI when it wants to start over.
    //
    public void reset(long seed) {
        prn.setSeed(seed);
        extreme = 1.0;
        for (int i = 0; i < nStars; i++) {
            // Use polar coordinates at first so both initial locations
            // and initial velocities are uniformly distributed around
            // the unit circle.
            final double lrho = prn.nextDouble();
            final double ltheta = prn.nextDouble() * Math.PI * 2.0;
            final double vrho = prn.nextDouble() * velocity;
            final double vtheta = prn.nextDouble() * Math.PI * 2.0;
            stars[i] = new Star(lrho * cos(ltheta), lrho * sin(ltheta),
                vrho * cos(vtheta), vrho * sin(vtheta));
            otherStars[i] = new Star();   // contents not needed yet
        }
        repaint();
            // tell graphic system that Space needs to be re-rendered
    }

    // These flags are set by external calls from the UI to alert us
    // when we need to change what we're doing.  They're volatile to
    // make racy accesses safe.
    private volatile boolean running = true;
    private volatile boolean killed = false;

    // We've been (re)initialized and the user wants us to start
    // simulating.
    public synchronized void start() {
        running = true;
        killed = false;
    }

    // The user wants us to stop simulating, presumably because the
    // Reset or Randomized button has been pushed.
    public synchronized void stop() {
        running = false;
        killed = true;
        notify();                   // wake up sleeping worker, if any
    }

    // The user wants us to switch betweeen running and paused.
    public synchronized void toggle() {
        running = !running;
        if (running) notify();      // wake up sleeping worker, if any
    }

    // Advance the simulation one time step.
    // Recall from high school physics that
    //      f = (G * m1 * m2) / r^2
    //           where r is the distance between objects
    //           and m1 and m2 are their masses
    //      a = f/m
    //      p = p0 + v0*t + .5*a*t^2
    //      v = d/dx p = v0 + at
    // Calculations here assume that all objects have mass 1,
    // and that t = 1.  Thus
    //      f = G / r^2
    //      a = f
    //      d = d0 + v0 + .5*a
    //      v = v0 + a
    // Now if points I and J are separated by dX and dY in
    // the X and Y dimentions, respectively, then the Euclidean distance
    // between then is r = sqrt(dX^2+dY^2).  The force between them is
    // G/(dX^2+dY^2).  The force in the X direction is G * (dX/r) / r^2
    // = G * dX / r^3.  The force in the Y direction is G * (dY/r) / r^2
    // = G * dY / r^3.  The _total_ forces on a given star are the sums
    // over the component forces induced by all the other stars:
    //      xForce = sum_i(G * dX/r/r^2) = G * sum_i(dX/r^3)
    //      yForce = sum_i(G * dY/r/r^2) = G * sum_i(dY/r^3)
    //
    private void doStep() {
        for (int i = 0; i < nStars; i++) {
            Star p = stars[i];
            double xForce = 0;  double yForce = 0;
            for (int j = 0; j < nStars; j++) {
                if (i != j) {   // don't act on self
                    final double dX = stars[j].xPos - stars[i].xPos;
                    final double dY = stars[j].yPos - stars[i].yPos;
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
        Star[] tmp = stars;
        stars = otherStars;
        otherStars = tmp;
    }

    // This is the entry point that Workers call to do the simulation.
    //
    public void simulate() {
        int i = 0;
        while (!killed) {
            if (stepLimit != 0 && i >= stepLimit) {
                // We've run as long as we were supposed to.
                repaint();          // repaints space
                stats.revise(i, (int) (extreme + 0.5));
                    // includes repaint of stats
                parent.pause();     // change default button
                return;
            }
            doStep();
            if (++i % displayStep == 0) {
                repaint();              // repaints space
                stats.revise(i, (int) extreme);
                    // includes repaint of stats
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

    // The following method is called automatically by the graphics
    // system when it thinks the Space canvas needs to be
    // re-displayed.  This can happen because code elsewhere in this
    // program called repaint(), or because of hiding/revealing or
    // open/close operations in the surrounding window system.
    //
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        setBackground(Color.black);
        for (int i = 0; i < nStars; i++) {
            stars[i].render(g);
        }
    }

    // Constructor
    //
    public Space(int B, int W, long S, double G,
                 double V, int X, int L, UI P, Stats U) {
        nStars = B;
        width = W;
        gravity = G;
        velocity = V;
        displayStep = X;
        stepLimit = L;
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

// Stats panel keeps track of seed, number of steps completed,
// elapsed run time, and display scale.
//
class Stats extends JPanel {
    private final JLabel timeL = new JLabel("time: 0   ");
    private final JLabel seedL = new JLabel("seed: 0   ");
    private final JLabel stepL = new JLabel("step: 0   ");
    private final JLabel scaleL = new JLabel("scale: 1   ");
    private long startTime = 0;     // beginning of current interval
    private long elapsedTime = 0;   // cumulative time across past intervals
    private boolean stopped = false;

    // now running; keep track of time
    //
    public synchronized void startClock() {
        startTime = System.currentTimeMillis();
        stopped = false;
    }

    // paused or stopped; stop tracking time
    //
    public synchronized void stopClock() {
        stopped = true;
    }

    // update stats
    //
    public synchronized void revise(int step, int scale) {
        final long inc = System.currentTimeMillis() - startTime;
        final long t = inc + elapsedTime;
        // arrange to update buttons on the graphics thread
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
        // arrange to update buttons on the graphics thread
        SwingUtilities.invokeLater(() -> {
            seedL.setText("seed: " + seed + "  ");
            stepL.setText("step: 0  ");
            timeL.setText("time: 0  ");
            scaleL.setText("scale: 1  ");
        });
        repaint();
    }

    // Constructor
    //
    public Stats(int ts, long seed) {
        // put the labels into the statistics panel:
        add(seedL);
        add(stepL);
        add(timeL);
        add(scaleL);
        reset(seed);
    }
}

// Class UI is the user interface.  It displays a Space canvas above a
// row of buttons and a row of statistics.  Actions (event handlers) are
// defined for each of the buttons.  Depending on the state of the UI,
// either the "run" or the "pause" button is the default (highlighted in
// most window systems); it will often self-push if you hit carriage
// return.
//
class UI extends JPanel {
    private final Space space;

    private final JRootPane root;
    private final int externalBorder = 6;

    private enum Status {STOPPED, RUNNING, PAUSED};
    private final JButton runButton;
        // Class variable so pause() can find it.

    private Status state = Status.STOPPED;
    private long seed;

    private Stats stats = null;     // statistics panel

    // Called from outside when the simulation has paused itself.
    public void pause() {
        root.setDefaultButton(runButton);
    }

    // Constructor
    //
    public UI(int B, int W, long S, double G, double V, int X, int L,
              RootPaneContainer pane) {
        final UI ui = this;
        seed = S;
        stats = new Stats(X, seed);   // statistics panel
        space = new Space(B, W, S, G, V, X, L, this, stats);

        final JPanel buttons = new JPanel();   // button panel

        runButton = new JButton("Run");
        final JButton pauseButton = new JButton("Pause");
        final JButton resetButton = new JButton("Reset");
        final JButton randomizeButton = new JButton("Randomize");
        final JButton quitButton = new JButton("Quit");

        final Collection<Worker> workers = new LinkedList<Worker>();

        // define event handlers for all the buttons:

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

        // put the buttons into the button panel:
        buttons.setLayout(new FlowLayout());
        buttons.add(runButton);
        buttons.add(pauseButton);
        buttons.add(resetButton);
        buttons.add(randomizeButton);
        buttons.add(quitButton);

        // put the Space canvas, the button panel, and the stats
        // label into the UI:
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setBorder(BorderFactory.createEmptyBorder(
            externalBorder, externalBorder, externalBorder, externalBorder));
        add(space);
        add(buttons);
        add(stats);

        // put the UI into the Frame
        pane.getContentPane().add(this);
        root = getRootPane();
        root.setDefaultButton(runButton);
    }
}