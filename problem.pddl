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
        (not (served d1 t2))
        (not (served d2 t2))
        (clean t1)
        (clean t2)
        (not (clean t3))
        (not (clean t4))

        ; general of the assignment
        (waiter wr)
        (not (waiter br))
        (not (busy wr))
        (not (busy br))
        (bar b)
        (= (holding wr) 0) ; we suppose the waiter initially with the greppers free
        (not (holding_tray wr))
        (not (holding_tray br))

        (not (drink_on_table d1 b))
        (not (drink_on_table d1 t1))
        (not (drink_on_table d1 t2))
        (not (drink_on_table d1 t3))
        (not (drink_on_table d1 t4))

        (not (drink_on_table d2 b))
        (not (drink_on_table d2 t1))
        (not (drink_on_table d2 t2))
        (not (drink_on_table d2 t3))
        (not (drink_on_table d2 t4))

        (not (drink_holded d1 wr))
        (not (drink_holded d1 br))
        (not (drink_holded d2 wr))
        (not (drink_holded d2 br))
        
        ; positions and dimensions
        (= (xt b) 1)
        (= (yt b) 4)
        ; bar dimension if we need to clean it
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

        (= (xr wr) 1) ; we suppose the waiter initially at the bar
        (= (yr wr) 3)

        (= (xr br) 1) ; we suppose the waiter initially at the bar
        (= (yr br) 4)

        (= (x_min) 0)
        (= (y_min) 0)
        (= (x_max) 3)
        (= (y_max) 5)

        (not (p_c_d_F d1 b))
        (not (p_c_d_F d1 t1))
        (not (p_c_d_F d1 t2))
        (not (p_c_d_F d1 t3))
        (not (p_c_d_F d1 t4))

        (not (p_c_d_F d2 b))
        (not (p_c_d_F d2 t1))
        (not (p_c_d_F d2 t2))
        (not (p_c_d_F d2 t3))
        (not (p_c_d_F d2 t4))

        (not (c_F wr b))
        (not (c_F wr t1))
        (not (c_F wr t2))
        (not (c_F wr t3))
        (not (c_F wr t4))

        (not (c_F br b))
        (not (c_F br t1))
        (not (c_F br t2))
        (not (c_F br t3))
        (not (c_F br t4))

        (= (p_d_C d1) 0)
        (= (p_d_C d2) 0)
        (= (c_C wr t3) 0)
        (= (c_C wr t4) 0)
        (= (m_C wr) 0)

        (not (uf wr))
        (not (lf wr))
        (not (rf wr))
        (not (df wr))
        (not (ulf wr))
        (not (urf wr))
        (not (dlf wr))
        (not (drf wr))
        (not (us wr))
        (not (ls wr))
        (not (rs wr))
        (not (ds wr))
        (not (uls wr))
        (not (urs wr))
        (not (dls wr))
        (not (drs wr))

        (not (uf br))
        (not (lf br))
        (not (rf br))
        (not (df br))
        (not (ulf br))
        (not (urf br))
        (not (dlf br))
        (not (drf br))
        (not (us br))
        (not (ls br))
        (not (rs br))
        (not (ds br))
        (not (uls br))
        (not (urs br))
        (not (dls br))
        (not (drs br))
        
    
    )

	(:goal
        ;(and (served d1 t2) (served d2 t2) (clean t3) (clean t4))
        (drink_on_table d1 b)
        
        
    )
)