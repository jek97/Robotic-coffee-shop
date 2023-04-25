;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)

(define (domain coffee_robot)

    ;(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effect :negative-preconditions :duration-inequalities :equality :time ::timed-effects)

    (:types
        drink -object
        robot -object
        table -location
    )

    (:predicates
        (hot_drink ?d -drink) ; T is an hot drink
        (cold_drink ?d -drink) ; T is a cold drink
        (served ?d -drink ?t -table) ; T if the drink d has passed by the table t

        (waiter ?r -robot) ; T if the robot is a waiter
        (barista ?r -robot) ; F if the robot is a barista
        (holding_tray ?r -robot) ; T if the robot r is holding a tray

        (bar ?t -table) ; T if the table is the bar
        (clean ?t -table) ; T if the table is clean
        (drink_on_table ?d -drink ?t -table) ; T if the drink d is on the table t
        (drink_holded ?d -drink ?r -robot) ; T if the drink d is holded by the robot r gripper

        ; flags for reproduce durative actions by actions-processes-event sequences
        (busy ?r -robot) ; T for the whole time of any durative action done by the robot r 
        (p_h_d_F ?d -drink ?t -table) ;prepare hot drink flag
        (p_c_d_F ?d -drink ?t -table) ;prepare cold drink flag
        (c_F ?r -robot ?t -table) ;cleaning flag
        (uf ?r) ; moving up fast flag
        (lf ?r) ; moving left fast flag
        (rf ?r) ; moving right fast flag
        (df ?r) ; moving down fast flag
        (ulf ?r) ; moving up left fast flag
        (urf ?r) ; moving up right fast flag
        (dlf ?r) ; moving down left fast flag
        (drf ?r) ; moving down right fast flag

        (us ?r) ; moving up slow flag
        (ls ?r) ; moving left slow flag
        (rs ?r) ; moving right slow flag
        (ds ?r) ; moving down slow flag
        (uls ?r) ; moving up left slow flag
        (urs ?r) ; moving up right slow flag
        (dls ?r) ; moving down left slow flag
        (drs ?r) ; moving down right slow flag 
    )


    (:functions 
        (xr ?r -robot) ; position x of the robot
        (yr ?r -robot) ; position y of the robot

        (xt ?t -table) ; position x of the table
        (yt ?t -table) ; position y of the table

        (x_min) ; minimum position x of the room
        (y_min) ; minimum position y of the room
        (x_max) ; maximum position x of the room
        (y_max) ; maximum position y of the room

        (t_dim ?t -table) ; dimension of the table
        (holding ?r -robot) ; number of drinks holded by the robot

        (p_h_d_c ?d -drink ?t -table) ; prepare hot drink counter
        (p_c_d_c ?d -drink ?t -table) ; prepare cold drink counter
        (c_C ?r -robot ?t -table) ; cleaning counter
        (m_uf_C ?r -robot) ; moving up fast counter
        (m_urf_C ?r -robot) ; moving up right fast counter
        (m_rf_C ?r -robot) ; moving right fast counter
        (m_drf_C ?r -robot) ; moving down right counter
        (m_df_C ?r -robot) ; moving down fast counter
        (m_dlf_C ?r -robot) ; moving down left fast counter
        (m_lf_C ?r -robot) ; moving left fast counter
        (m_ulf_C ?r -robot) ; moving up left fast counter

        (m_us_C ?r -robot) ; moving up slow counter
        (m_urs_C ?r -robot) ; moving up right slow counter
        (m_rs_C ?r -robot) ; moving right slow counter
        (m_drs_C ?r -robot) ; moving down right slow counter
        (m_ds_C ?r -robot) ; moving down slow counter
        (m_dls_C ?r -robot) ; moving down left slow counter
        (m_ls_C ?r -robot) ; moving left slow counter
        (m_uls_C ?r -robot) ; moving up left slow counter
    )

    ;; to enable the robot to move at different speeds in a grid like environment we assume the time unit equal to 2 time unit of the planner

    ; preparing drinks
    (:action Hot_drink_Prepare ; initial action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (hot_drink ?d) (barista ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (not (busy ?r)))
        :effect (and (p_h_d_F ?d ?t) (assign (p_h_d_c ?d ?t) 0) (busy ?r))
    )    
    (:process Hot_drink_Preparing ; process mimiking the durative action
        :parameters (?d -drink ?t -table)
        :precondition (or (p_h_d_F ?d ?t))
        :effect (increase (p_h_d_c ?d ?t) (* #t 1.0))
    )
    (:event Hot_drink_Prepared ; event to conclude the action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (p_h_d_F ?d ?t) (= (p_h_d_c ?d ?t) 10))
        :effect (and (drink_on_table ?d ?t) (assign (p_h_d_c ?d ?t) 0) (not (p_h_d_F ?d ?t)) (not (busy ?r)))
    )
    

    (:action Cold_drink_Prepare
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (cold_drink ?d) (barista ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (not (busy ?r)))
        :effect (and (p_c_d_F ?d ?t) (assign (p_c_d_c ?d ?t) 0) (busy ?r))
    )    
    (:process Cold_drink_Preparing
        :parameters (?d -drink ?t -table)
        :precondition (or (p_c_d_F ?d ?t))
        :effect (increase (p_c_d_c ?d ?t) (* #t 1.0))
    )
    (:event Cold_drink_Prepared
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (p_c_d_F ?d ?t) (= (p_c_d_c ?d ?t) 6))
        :effect (and (drink_on_table ?d ?t) (assign (p_c_d_c ?d ?t) 0) (not (p_c_d_F ?d ?t)) (not (busy ?r)))
    )
    

    ; cleaning
    (:action Clean_init
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (not (holding_tray ?r)) (= (holding ?r) 0) (not (clean ?t)))
        :effect (and (c_F ?r ?t) (assign (c_C ?r ?t) 0))
    )    
    (:process Cleaning
        :parameters (?r -robot ?t -table)
        :precondition (c_F ?r ?t)
        :effect (increase (c_C ?r ?t) (* #t 1.0))
    )
    (:event Cleaned
        :parameters (?r -robot ?t -table)
        :precondition (and (c_F ?r ?t) (= (c_C ?r ?t) (* (t_dim ?t) 4 )))
        :effect (and (clean ?t) (assign (c_C ?r ?t) 0) (not (c_F ?r ?t)))
    )


    ; pick-up, put-down drinks and tray
    (:action Pick_up_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t) (not (busy ?r)))
        :effect (and (increase (holding ?r) 1) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    
    (:action Put_down_drink
        :parameters (?r -robot ?t -table ?d -drink)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (drink_holded ?d ?r) (not (busy ?r)))
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t) (served ?d ?t))
    )
    
    (:action Pick_up_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0) (not (busy ?r)))
        :effect (holding_tray ?r)
    )
    
    (:action Put_down_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (holding_tray ?r) (= (holding ?r) 0) (not (busy ?r)))
        :effect (not (holding_tray ?r))
    )
    
    ; space constraint
    (:constraint X_constraint
        :parameters (?r -robot)
        :condition (and (<= (xr ?r) x_max) (>= (xr ?r) x_min))
    ) 
    (:constraint Y_constraint
        :parameters (?r -robot)
        :condition (and (<= (yr ?r) y_max) (>= (yr ?r) y_min))
    ) 

    ; moving actions
    ;if the robot is not holding the tray it can move at 2 m/tu, that means under our time unit of 2 sec a velocity of 1 m/s

    (:action Move_up_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and (assign (m_uf_C ?r) 0) (uf ?r) (busy ?r))
    )  
    (:process Moving_up_fast
        :parameters (?r -robot)
        :precondition (uf ?r)
        :effect (increase (m_uf_C ?r) (* #t 1.0))
    )    
    (:event Moved_up_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_uf_C ?r) 1) (uf ?r))
        :effect (and (increase (yr ?r) 1) (assign (m_uf_C ?r) 0) (not (uf ?r)) (not (busy ?r)))
    )


    (:action Move_down_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and (assign (m_df_C ?r) 0) (df ?r) (busy ?r))
    )
    (:process Moving_down_fast
        :parameters (?r -robot)
        :precondition (df ?r)
        :effect (increase (m_df_C ?r) (* #t 1.0))
    ) 
    (:event Moved_down_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_df_C ?r) 1) (df ?r))
        :effect (and (decrease (yr ?r) 1) (assign (m_df_C ?r) 0) (not (df ?r)) (not (busy ?r)))
    )   
    

    (:action Move_left_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (x_min) (- (xr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and (assign (m_lf_C ?r) 0) (lf ?r) (busy ?r))
    )
    (:process Moving_left_fast
        :parameters (?r -robot)
        :precondition (lf ?r)
        :effect (increase (m_lf_C ?r) (* #t 1.0))
    ) 
    (:event Moved_left_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_lf_C ?r) 1) (lf ?r))
        :effect (and (decrease (xr ?r) 1) (assign (m_lf_C ?r) 0) (not (lf ?r)) (not (busy ?r)))
    )  

    
    (:action Move_right_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (x_max) (+ (xr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and (assign (m_rf_C ?r) 0) (rf ?r) (busy ?r))
    )
    (:process Moving_right_fast
        :parameters (?r -robot)
        :precondition (rf ?r)
        :effect (increase (m_rf_C ?r) (* #t 1.0))
    ) 
    (:event Moved_right_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_rf_C ?r) 1) (rf ?r))
        :effect (and (increase (xr ?r) 1) (assign (m_rf_C ?r) 0) (not (rf ?r)) (not (busy ?r)))
    )  

    
    (:action Move_up_right_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and (assign (m_urf_C ?r) 0) (urf ?r) (busy ?r))
    )
    (:process Moving_up_right_fast
        :parameters (?r -robot)
        :precondition (urf ?r)
        :effect (increase (m_urf_C ?r) (* #t 1.0))
    ) 
    (:event Moved_up_right_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_urf_C ?r) 1) (urf ?r))
        :effect (and (increase (yr ?r) 1) (increase (xr ?r) 1) (assign (m_urf_C ?r) 0) (not (urf ?r)) (not (busy ?r)))
    ) 


    (:action Move_up_left_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and  (assign (m_ulf_C ?r) 0) (ulf ?r) (busy ?r))
    )
    (:process Moving_up_left_fast
        :parameters (?r -robot)
        :precondition (ulf ?r)
        :effect (increase (m_ulf_C ?r) (* #t 1.0))
    ) 
    (:event Moved_up_left_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_ulf_C ?r) 1) (ulf ?r))
        :effect (and (increase (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_ulf_C ?r) 0) (not (ulf ?r)) (not (busy ?r)))
    )  


    (:action Move_down_right_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and (assign (m_drf_C ?r) 0) (drf ?r) (busy ?r))
    )
    (:process Moving_down_right_fast
        :parameters (?r -robot)
        :precondition (drf ?r)
        :effect (increase (m_drf_C ?r) (* #t 1.0))
    ) 
    (:event Moved_down_right_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_drf_C ?r) 1) (drf ?r))
        :effect (and (decrease (yr ?r) 1) (increase (xr ?r) 1) (assign (m_drf_C ?r) 0) (not (drf ?r)) (not (busy ?r)))
    )  


    (:action Move_down_left_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (not (busy ?r)) (not (holding_tray ?r)))
        :effect (and (assign (m_dlf_C ?r) 0) (dlf ?r) (busy ?r))
    )
    (:process Moving_down_left_fast
        :parameters (?r -robot)
        :precondition (dlf ?r)
        :effect (increase (m_dlf_C ?r) (* #t 1.0))
    ) 
    (:event Moved_down_left_fast
        :parameters (?r -robot)
        :precondition (and (>= (m_dlf_C ?r) 1) (dlf ?r))
        :effect (and (decrease (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_dlf_C ?r) 0) (not (dlf ?r)) (not (busy ?r)))
    )  


    ;if the robot is holding the tray it can move at 1 m/tu, that means under our time unit of 2 sec a velocity of 0.5 m/s

    (:action Move_up_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and (assign (m_us_C ?r) 0) (us ?r) (busy ?r))
    )  
    (:process Moving_up_slow
        :parameters (?r -robot)
        :precondition (us ?r)
        :effect (increase (m_us_C ?r) (* #t 1.0))
    )    
    (:event Moved_up_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_us_C ?r) 2) (us ?r))
        :effect (and (increase (yr ?r) 1) (assign (m_us_C ?r) 0) (not (us?r)) (not (busy ?r)))
    )


    (:action Move_down_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and (assign (m_ds_C ?r) 0) (ds ?r) (busy ?r))
    )
    (:process Moving_down_slow
        :parameters (?r -robot)
        :precondition (ds ?r)
        :effect (increase (m_ds_C ?r) (* #t 1.0))
    ) 
    (:event Moved_down_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_ds_C ?r) 2) (ds ?r))
        :effect (and (decrease (yr ?r) 1) (assign (m_ds_C ?r) 0) (not (ds ?r)) (not (busy ?r)))
    )   
    

    (:action Move_left_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (x_min) (- (xr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and (assign (m_ls_C ?r) 0) (ls ?r) (busy ?r))
    )
    (:process Moving_left_slow
        :parameters (?r -robot)
        :precondition (ls ?r)
        :effect (increase (m_ls_C ?r) (* #t 1.0))
    ) 
    (:event Moved_left_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_ls_C ?r) 2) (ls ?r))
        :effect (and (decrease (xr ?r) 1) (assign (m_ls_C ?r) 0) (not (ls ?r)) (not (busy ?r)))
    )  

    
    (:action Move_right_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (x_max) (+ (xr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and (assign (m_rs_C ?r) 0) (rs ?r) (busy ?r))
    )
    (:process Moving_right_slow
        :parameters (?r -robot)
        :precondition (rs ?r)
        :effect (increase (m_rs_C ?r) (* #t 1.0))
    ) 
    (:event Moved_right_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_rs_C ?r) 2) (rs ?r))
        :effect (and (increase (xr ?r) 1) (assign (m_rs_C ?r) 0) (not (rs ?r)) (not (busy ?r)))
    )  

    
    (:action Move_up_right_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and (assign (m_urs_C ?r) 0) (urs ?r) (busy ?r))
    )
    (:process Moving_up_right_slow
        :parameters (?r -robot)
        :precondition (urs ?r)
        :effect (increase (m_urs_C ?r) (* #t 1.0))
    ) 
    (:event Moved_up_right_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_urs_C ?r) 2) (urs ?r))
        :effect (and (increase (yr ?r) 1) (increase (xr ?r) 1) (assign (m_urs_C ?r) 0) (not (urs ?r)) (not (busy ?r)))
    ) 


    (:action Move_up_left_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and  (assign (m_uls_C ?r) 0) (uls ?r) (busy ?r))
    )
    (:process Moving_up_left_slow
        :parameters (?r -robot)
        :precondition (uls ?r)
        :effect (increase (m_uls_C ?r) (* #t 1.0))
    ) 
    (:event Moved_up_left_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_uls_C ?r) 2) (uls ?r))
        :effect (and (increase (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_uls_C ?r) 0) (not (uls ?r)) (not (busy ?r)))
    )  


    (:action Move_down_right_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and (assign (m_drs_C ?r) 0) (drs ?r) (busy ?r))
    )
    (:process Moving_down_right_slow
        :parameters (?r -robot)
        :precondition (drs ?r)
        :effect (increase (m_drs_C ?r) (* #t 1.0))
    ) 
    (:event Moved_down_right_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_drs_C ?r) 2) (drs ?r))
        :effect (and (decrease (yr ?r) 1) (increase (xr ?r) 1) (assign (m_drs_C ?r) 0) (not (drs ?r)) (not (busy ?r)))
    )  


    (:action Move_down_left_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (not (busy ?r)) (holding_tray ?r))
        :effect (and (assign (m_dls_C ?r) 0) (dls ?r) (busy ?r))
    )
    (:process Moving_down_left_slow
        :parameters (?r -robot)
        :precondition (dls ?r)
        :effect (increase (m_dls_C ?r) (* #t 1.0))
    ) 
    (:event Moved_down_left_slow
        :parameters (?r -robot)
        :precondition (and (>= (m_dls_C ?r) 2) (dls ?r))
        :effect (and (decrease (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_dls_C ?r) 0) (not (dls ?r)) (not (busy ?r)))
    )  
)