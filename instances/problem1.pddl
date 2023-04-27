
;;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)

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
        (cold_drink d1)
        (cold_drink d2)
        (= (drink_temperature d1) 0)
        (= (drink_temperature d2) 0)

        (clean t1)
        (clean t2)
        (bar b)
        (= (xt b) 1)
        (= (yt b) 4)
        (= (t_dim b) 2)
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
        (= (x_min) 0)
        (= (y_min) 0)
        (= (x_max) 3)
        (= (y_max) 5)

        (waiter wr)
        (barista br)
        (= (holding wr) 0)
        (= (holding br) 0)
        (= (xr wr) 1) 
        (= (yr wr) 4)
        (= (xr br) 1) 
        (= (yr br) 4)  
    
    )

	(:goal
        (and (served_cold_drink d1 t2) (served_cold_drink d2 t2) (clean t3) (clean t4))   
    )
    (:metric minimize ( total-time ))
)