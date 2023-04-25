;;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)
(define (problem instance_3)

(:domain coffee_robot)

	(:objects
        ;; specific of the problem
		d1 -drink
        d2 -drink
        d3 -drink
        d4 -drink

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
        (hot_drink d1)
        (hot_drink d2)
        (hot_drink d3)
        (hot_drink d4)

        (clean b)
        (clean t1)
        (clean t2)
        (clean t4)
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

        (= (p_c_d_c d1 b) 0)
        (= (p_c_d_c d1 t1) 0)
        (= (p_c_d_c d1 t2) 0)
        (= (p_c_d_c d1 t3) 0)
        (= (p_c_d_c d1 t4) 0)
        (= (p_c_d_c d2 b) 0)
        (= (p_c_d_c d2 t1) 0)
        (= (p_c_d_c d2 t2) 0)
        (= (p_c_d_c d2 t3) 0)
        (= (p_c_d_c d2 t4) 0)

        (= (p_h_d_c d1 b) 0)
        (= (p_h_d_c d1 t1) 0)
        (= (p_h_d_c d1 t2) 0)
        (= (p_h_d_c d1 t3) 0)
        (= (p_h_d_c d1 t4) 0)
        (= (p_h_d_c d2 b) 0)
        (= (p_h_d_c d2 t1) 0)
        (= (p_h_d_c d2 t2) 0)
        (= (p_h_d_c d2 t3) 0)
        (= (p_h_d_c d2 t4) 0)

        (= (p_c_d_c d3 b) 0)
        (= (p_c_d_c d3 t1) 0)
        (= (p_c_d_c d3 t2) 0)
        (= (p_c_d_c d3 t3) 0)
        (= (p_c_d_c d3 t4) 0)
        (= (p_c_d_c d4 b) 0)
        (= (p_c_d_c d4 t1) 0)
        (= (p_c_d_c d4 t2) 0)
        (= (p_c_d_c d4 t3) 0)
        (= (p_c_d_c d4 t4) 0)

        (= (p_h_d_c d3 b) 0)
        (= (p_h_d_c d3 t1) 0)
        (= (p_h_d_c d3 t2) 0)
        (= (p_h_d_c d3 t3) 0)
        (= (p_h_d_c d3 t4) 0)
        (= (p_h_d_c d4 b) 0)
        (= (p_h_d_c d4 t1) 0)
        (= (p_h_d_c d4 t2) 0)
        (= (p_h_d_c d4 t3) 0)
        (= (p_h_d_c d4 t4) 0)
        
        (= (c_C wr b) 0)
        (= (c_C wr t1) 0)
        (= (c_C wr t2) 0)
        (= (c_C wr t3) 0)
        (= (c_C wr t4) 0)
        (= (c_C br b) 0)
        (= (c_C br t1) 0)
        (= (c_C br t2) 0)
        (= (c_C br t3) 0)
        (= (c_C br t4) 0)

        (= (m_uf_C wr) 0)
        (= (m_urf_C wr) 0)
        (= (m_rf_C wr) 0) 
        (= (m_drf_C wr) 0)
        (= (m_df_C wr) 0) 
        (= (m_dlf_C wr) 0)
        (= (m_lf_C wr) 0) 
        (= (m_ulf_C wr) 0)
        (= (m_us_C wr) 0) 
        (= (m_urs_C wr) 0)
        (= (m_rs_C wr) 0) 
        (= (m_drs_C wr) 0)
        (= (m_ds_C wr) 0) 
        (= (m_dls_C wr) 0)
        (= (m_ls_C wr) 0) 
        (= (m_uls_C wr) 0) 

        (= (m_uf_C br) 0)
        (= (m_urf_C br) 0)
        (= (m_rf_C br) 0) 
        (= (m_drf_C br) 0)
        (= (m_df_C br) 0) 
        (= (m_dlf_C br) 0)
        (= (m_lf_C br) 0) 
        (= (m_ulf_C br) 0)
        (= (m_us_C br) 0) 
        (= (m_urs_C br) 0)
        (= (m_rs_C br) 0) 
        (= (m_drs_C br) 0)
        (= (m_ds_C br) 0) 
        (= (m_dls_C br) 0)
        (= (m_ls_C br) 0) 
        (= (m_uls_C br) 0)     
    
    )

	(:goal
        (and (served d1 t1) (served d2 t1) (served d3 t4) (served d4 t4) (clean t3))
        
    )
)