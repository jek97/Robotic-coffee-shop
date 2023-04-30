;;Luca Sortino, Bauyrzhan Zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)
(define (problem instance_4)

(:domain coffee_robot)

	(:objects
        ;; specific of the problem
		d1 -drink
        d2 -drink
        d3 -drink
        d4 -drink
        d5 -drink
        d6 -drink
        d7 -drink
        d8 -drink
        
        ;; cookies
	    bis1 -biscuit
        ; bis2 -biscuit
        ; bis3 -biscuit
        ; bis4 -biscuit

        ;; general of the assignment
        b -table 
        t1 -table
        t2 -table
        t3 -table
        t4 -table

        wr -robot 
        br -robot 

	)

    (:init
        ;predicates
        (waiter wr) ; T if the robot is a waiter, F if is a barista

        (hot_drink d5)
        (hot_drink d6)
        (hot_drink d7)
        (hot_drink d8)

        (biscuit_n bis1)
        ; (biscuit_n bis2)
        ; (biscuit_n bis3)
        ; (biscuit_n bis4)

        (biscuit_on_table bis1 b)
        ; (biscuit_on_table bis2 b)
        ; (biscuit_on_table bis3 b)
        ; (biscuit_on_table bis4 b)

        (bar b) ; T if the table is the bar
        (clean t1) ; T if the table is clean
        (clean t2) ; T if the table is clean
        (clean t3) ; T if the table is clean
        (not (clean t4))
        
        (robot_pos wr b) ; robot position, thet table at which the robot is
        (robot_pos br b) ; robot position, thet table at which the robot is

        ;functions
        (= (dist b t1) 2) ; distance between two tables
        (= (dist b t2) 2) ; distance between two tables
        (= (dist b t3) 3) ; distance between two tables
        (= (dist b t4) 3) ; distance between two tables

        (= (dist t1 b) 2) ; distance between two tables
        (= (dist t1 t2) 1) ; distance between two tables
        (= (dist t1 t3) 1) ; distance between two tables
        (= (dist t1 t4) 1) ; distance between two tables

        (= (dist t2 b) 2) ; distance between two tables
        (= (dist t2 t1) 1) ; distance between two tables
        (= (dist t2 t3) 1) ; distance between two tables
        (= (dist t2 t4) 1) ; distance between two tables

        (= (dist t3 b) 3) ; distance between two tables
        (= (dist t3 t1) 1) ; distance between two tables
        (= (dist t3 t2) 1) ; distance between two tables
        (= (dist t3 t3) 1) ; distance between two tables

        (= (dist t4 b) 3) ; distance between two tables
        (= (dist t4 t1) 1) ; distance between two tables
        (= (dist t4 t2) 1) ; distance between two tables
        (= (dist t4 t3) 1) ; distance between two tables

        (= (tim wr) 150) ; valeu of the timer
        (= (tim br) 150) ; valeu of the timer

        (= (t_dim t1) 1) ; dimension of the table
        (= (t_dim t2) 1) ; dimension of the table
        (= (t_dim t3) 2) ; dimension of the table
        (= (t_dim t4) 1) ; dimension of the table

        (= (holding wr) 0) ; number of drinks holded by the robot
        (= (holding br) 0) ; number of drinks holded by the robot
    )

	(:goal
        ;(and (drink_on_table d1 t4) (drink_on_table d2 t4) (drink_on_table d3 t1) (drink_on_table d4 t1) (drink_on_table d5 t3) (drink_on_table d6 t3) (drink_on_table d7 t3) (drink_on_table d8 t3) (biscuit_on_table bis1 t1) (biscuit_on_table bis2 t1) (biscuit_on_table bis3 t4) (biscuit_on_table bis4 t4) (clean t4))
        (and (drink_on_table d1 t4) (biscuit_on_table bis1 t4))
    )
)
