;;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano

(define (problem instance_1)

(:domain coffee_robot)

	(:objects
        ;; specific of the problem
		d1 -drink
        d2 -drink

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
        ;; specific of the problem
        (cold_drink d1)
        (cold_drink d2)
        (clean t1)
        (clean t2)

        ;; general of the assignment
        (waiter wr)
        (bar b)
        (= (holding wr) 0)
        
        (= (xt b) 1)
        (= (yt b) 4)
        (= (xt t1) 1)
        (= (yt t1) 2)
        (= (t_dim t1) 1)
        (= (xt t2) 2)
        (= (yt t2) 2)
        (= (t_dim t2) 1)
        (= (xt t3) 1)
        (= (yt t3) 1)
        (= (t_dim t3) 2)
        (= (xt t4) 2)
        (= (yt t4) 1)
        (= (t_dim t4) 1)

        (= (xr wr) 1) 
        (= (yr wr) 3)

        (= (xr br) 1) 
        (= (yr br) 4)

        (= (x_min) 0)
        (= (y_min) 0)
        (= (x_max) 3)
        (= (y_max) 5)

        (= (p_d_C d1) 0)
        (= (p_d_C d2) 0)
        (= (c_C wr t3) 0)
        (= (c_C wr t4) 0)
        (= (m_C wr) 0)        
    
    )

	(:goal
        ;;(and (served d1 t2) (served d2 t2) (clean t3) (clean t4))
        (holding_tray wr)
        
        
    )
)