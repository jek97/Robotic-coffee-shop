;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano
; type of planner s gbfs -ties smaller_g and -h haddabs (same as Ijcai 2018)

(define (problem instance_1)

(:domain coffee_robot)

	(:objects
        ; specific of the problem
		d1 -drink
        d2 -drink

        ; general of the assignment
        b -table ; bar
        t1 -table
        t2 -table
        t3 -table
        t4 -table

        wr -robot ;waiter robot
        br -robot ;barista robot

	)

    (:init
        ; specific of the problem
        (cold_drink d1)
        (cold_drink d2)
        ;(not (served d1 t2))
        ;(not (served d2 t2))
        (clean t1)
        (clean t2)
        ;(not (clean t3))
        ;(not (clean t4))

        ; general of the assignment
        (Waiter wr)
        ;(not (busy wr))
        ;(not (busy br))
        (bar b)
        (= (holding wr) 0) ; we suppose the waiter initially with the greppers free
        
        ; positions and dimensions
        (= (x b) 1)
        (= (y b) 4)
        ; bar dimension if we need to clean it
        (= (x t1) 1)
        (= (y t1) 2)
        (= (t_dim t1) 1)
        (= (x t2) 2)
        (= (y t2) 2)
        (= (t_dim t2) 1)
        (= (x t3) 1)
        (= (y t3) 1)
        (= (t_dim t3) 2)
        (= (x t4) 2)
        (= (y t4) 1)
        (= (t_dim t4) 1)

        (= (x wr) 1) ; we suppose the waiter initially at the bar
        (= (y wr) 4)

        (= (x_min) 0)
        (= (y_min) 0)
        (= (x_max) 3)
        (= (y_max) 5)

        ;(p_h_d_C ?d -drink ?t -table) ;prepare hot drink counter
        (= (p_c_d_C d1 b) 0)
        (= (p_c_d_C d2 b) 0)
        (= (c_C wr t3) 0)
        (= (c_C wr t4) 0)
        (= (mf_C wr) 0)
        (= (ms_C wr) 0)
    
    )

	(:goal
        (and (served d1 t2) (served d2 t2) (clean t3) (clean t4))

    )
)