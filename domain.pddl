;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano
; type of planner -s gbfs -ties smaller_g and -h haddabs (same as Ijcai 2018)

(define (domain coffee_robot)

;remove requirements that are not needed
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effect :negative-preconditions :duration-inequalities :equality)

    (:types ;enumerate types and their hierarchy here, e.g. car truck bus - vehicle
        drink -object
        robot -object
        table -location
    )

    (:predicates ;define predicates here
        (hot_drink ?d -drink) 
        (cold_drink ?d -drink)
        (served ?d -drink ?t -table) ;true if the drink d has reached the table t as ordered

        (waiter ?r -robot) ; true if the robot is a waiter, false if it's a barista
        (barista ?r -robot)
        (holding_tray ?r -robot)

        (bar ?t -table)
        (clean ?t -table) ; true if the table is clean
        (drink_on_table ?d -drink ?t -table)
        (drink_holded ?d -drink ?r -robot)

        ; flags for switching from durative actions to actions-processes
        (busy ?r -robot) ; flag to say that the robot is doing a durative action, in such a way it doesn't start a new one in the meanwhile 
        (p_h_d_F ?d -drink ?t -table) ;prepare hot drink flag
        (p_c_d_F ?d -drink ?t -table) ;prepare cold drink flag
        (c_F ?r -robot ?t -table) ;cleaning flag
        ; flag for relate each action with its own event
        (uf ?r)
        (lf ?r)
        (rf ?r)
        (df ?r)
        (ulf ?r)
        (urf ?r)
        (dlf ?r)
        (drf ?r)
        (us ?r)
        (ls ?r)
        (rs ?r)
        (ds ?r)
        (uls ?r)
        (urs ?r)
        (dls ?r)
        (drs ?r)

    )


    (:functions ;define numeric functions here
        (xr ?r -robot) ; position x of the robot (needed only for the waiter)
        (yr ?r -robot) ; position y of the robot (needed only for the waiter)

        (xt ?t -table) ; position x of the table
        (yt ?t -table) ; position y of the robot

        (x_min) ; minimum position x of the room
        (y_min) ; minimum position y of the room
        (x_max) ; maximum position x of the room
        (y_max) ; maximum position y of the room

        (t_dim ?t -table) ; dimension of the table
        (holding ?r -robot) ; number of drinks holded by the robot

        ;function to control the processes to simulate durative actions
        (p_d_C ?d -drink) ;prepare drink counter
        (c_C ?r -robot ?t -table) ;cleaning counter
        (m_C ?r -robot) ;moving counter
    )

    ;; to enable the robot to move at different speeds in a grid like environment we assume the time unit equal to 2 time unit of the planner
    ; barista actions

    (:process drink_Preparing
        :parameters (?d -drink ?t -table)
        :precondition (or (p_h_d_F ?d ?t) (p_c_d_F ?d ?t))
        :effect (increase (p_d_C ?d) (* #t 1.0))
    )
    ;(:constraint max_drink_Preparing_duration
    ;    :parameters (?d -drink ?t -table)
    ;    :condition (<= (p_d_C ?d) 10)
    ;)

    (:action Hot_drink_Prepare
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (hot_drink ?d) (barista ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t))
        :effect (and (p_h_d_F ?d ?t) (assign (p_d_C ?d) 0))
    )    
    (:event Hot_drink_Prepared
        :parameters (?d -drink ?t -table ?r -robot)
        :precondition (and (p_h_d_F ?d ?t) (= (p_d_C ?d) 10))
        :effect (and (drink_on_table ?d ?t) (assign (p_d_C ?d) 0) (not (p_h_d_F ?d ?t)))
    )
    
    (:action Cold_drink_Prepare
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (cold_drink ?d) (barista ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t))
        :effect (and (p_c_d_F ?d ?t) (assign (p_d_C ?d) 0))
    )    
    (:event Cold_drink_Prepared
        :parameters (?d -drink ?t -table ?r -robot)
        :precondition (and (p_c_d_F ?d ?t) (= (p_d_C ?d) 6))
        :effect (and (drink_on_table ?d ?t) (assign (p_d_C ?d) 0) (not (p_c_d_F ?d ?t)))
    )
    
    ; drink serving and cleaning
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
    ;(:constraint Cleaning_duration
    ;    :parameters (?r -robot ?t -table)
    ;    :condition (<= (p_c_d_C ?r ?t) (* (t_dim ?t) 4 ))
    ;)
    
    (:event Drink_served
        :parameters (?d -drink ?t -table)
        :precondition (drink_on_table ?d ?t)
        :effect (served ?d ?t) ; logically it should go also (not (clean ?t)) just to say that if i put a drink on the table then i will need to clean it
    )    

    ; pick-up, put-down drinks actions module
    (:action Pick_up_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t)  )
        :effect (and (increase (holding ?r) 1) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    
    (:action Put_down_drink
        :parameters (?r -robot ?t -table ?d -drink)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (drink_holded ?d ?r)  )
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t))
    )
    
    (:action Pick_up_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0)  )
        :effect (holding_tray ?r)
    )
    
    (:action Put_down_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (holding_tray ?r) (= (holding ?r) 0)  )
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

    ; moving actions module
    ;if the robot is not holding the tray it can move at 2 m/tu
    (:process Moving
        :parameters (?r -robot)
        :precondition (or (uf ?r)(lf ?r)(rf ?r)(df ?r)(ulf ?r)(urf ?r)(dlf ?r)(drf ?r)(us ?r)(ls ?r)(rs ?r)(ds ?r)(uls ?r)(urs ?r)(dls ?r)(drs ?r))
        :effect (increase (m_C ?r) (* #t 1.0))
    )
    (:constraint Moving_max_duration
        :parameters (?r -robot)
        :condition (<= (m_C ?r) 2)
    )

    (:action Move_up_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (not (holding_tray ?r)))
        :effect (and (assign (m_C ?r) 0) (uf ?r))
    )    
    
    (:event Moved_up_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (uf ?r))
        :effect (and (increase (yr ?r) 1) (assign (m_C ?r) 0) (not (uf ?r)))
    )

    (:action Move_down_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (not (holding_tray ?r)))
        :effect (and (assign (m_C ?r) 0) (df ?r))
    )
    (:event Moved_down_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (df ?r))
        :effect (and (decrease (yr ?r) 1) (assign (m_C ?r) 0) (not (df ?r)))
    )   
    
    (:action Move_left_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (x_min) (- (xr ?r) 1)) (not (holding_tray ?r)))
        :effect (and (assign (m_C ?r) 0) (lf ?r))
    )
    (:event Moved_left_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (lf ?r))
        :effect (and (decrease (xr ?r) 1) (assign (m_C ?r) 0) (not (lf ?r)))
    )   
    
    (:action Move_right_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (x_max) (+ (xr ?r) 1)) (not (holding_tray ?r)))
        :effect (and (assign (m_C ?r) 0) (rf ?r))
    )
    (:event Moved_right_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (rf ?r))
        :effect (and (increase (xr ?r) 1) (assign (m_C ?r) 0) (not (rf ?r)))
    )  
    
    (:action Move_up_right_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (not (holding_tray ?r)))
        :effect (and (assign (m_C ?r) 0) (urf ?r))
    )
    (:event Moved_up_right_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (urf ?r))
        :effect (and (increase (yr ?r) 1) (increase (xr ?r) 1) (assign (m_C ?r) 0) (not (urf ?r)))
    )  

    (:action Move_up_left_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (not (holding_tray ?r)))
        :effect (and  (assign (m_C ?r) 0) (ulf ?r))
    )
    (:event Moved_up_left_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (ulf ?r))
        :effect (and (increase (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_C ?r) 0) (not (ulf ?r)))
    )  

    (:action Move_down_right_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (not (holding_tray ?r)))
        :effect (and (assign (m_C ?r) 0) (drf ?r))
    )
    (:event Moved_down_right_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (drf ?r))
        :effect (and (decrease (yr ?r) 1) (increase (xr ?r) 1) (assign (m_C ?r) 0) (not (drf ?r)))
    )  

    (:action Move_down_left_fast_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (not (holding_tray ?r)))
        :effect (and (assign (m_C ?r) 0) (dlf ?r))
    )
    (:event Moved_down_left_fast
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 1) (dlf ?r))
        :effect (and (decrease (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_C ?r) 0) (not (dlf ?r)))
    )  

    ; if the robot is holding the tray it can move at 1 m/tu
    (:action Move_up_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (us ?r))
    )    

    (:event Moved_up_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (us ?r))
        :effect (and (increase (yr ?r) 1) (assign (m_C ?r) 0) (not (us ?r)))
    )
    
    (:action Move_down_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (ds ?r))
    )
    (:event Moved_down_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (ds ?r))
        :effect (and (decrease (yr ?r) 1) (assign (m_C ?r) 0) (not (ds ?r)))
    )   
    
    (:action Move_left_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (x_min) (- (xr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (ls ?r))
    )
    (:event Moved_left_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (ls ?r))
        :effect (and (decrease (xr ?r) 1) (assign (m_C ?r) 0) (not (ls ?r)))
    )   
    
    (:action Move_right_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (x_max) (+ (xr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (rs ?r))
    )
    (:event Moved_right_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (rs ?r))
        :effect (and (increase (xr ?r) 1) (assign (m_C ?r) 0) (not (rs ?r)))
    )  
    
    (:action Move_up_right_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (urs ?r))
    )
    (:event Moved_up_right_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (urs ?r))
        :effect (and (increase (yr ?r) 1) (increase (xr ?r) 1) (assign (m_C ?r) 0) (not (urs ?r)))
    )  

    (:action Move_up_left_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (>= (y_max) (+ (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (uls ?r))
    )
    (:event Moved_up_left_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (uls ?r))
        :effect (and (increase (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_C ?r) 0) (not (uls ?r)))
    )  

    (:action Move_down_right_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (drs ?r))
    )
    (:event Moved_down_right_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (drs ?r))
        :effect (and (decrease (yr ?r) 1) (increase (xr ?r) 1) (assign (m_C ?r) 0) (not (drs ?r)))
    )  

    (:action Move_down_left_slow_init
        :parameters (?r -robot)
        :precondition (and (waiter ?r) (<= (y_min) (- (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1)) (holding_tray ?r))
        :effect (and (assign (m_C ?r) 0) (dls ?r))
    )
    (:event Moved_down_left_slow
        :parameters (?r -robot)
        :precondition (and (= (m_C ?r) 2) (dls ?r))
        :effect (and (decrease (yr ?r) 1) (decrease (xr ?r) 1) (assign (m_C ?r) 0) (not (dls ?r)))
    )  
)