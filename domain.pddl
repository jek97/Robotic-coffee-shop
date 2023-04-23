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

        (Waiter ?r -robot) ; true if the robot is a waiter, false if it's a barista
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
        (mf_F ?r -robot) ;moving fast flag
        (ms_F ?r -robot) ;moving slow flag

    )


    (:functions ;define numeric functions here
        (x ?r -robot) ; position x of the robot (needed only for the waiter)
        (y ?r -robot) ; position y of the robot (needed only for the waiter)

        (x ?t -table) ; position x of the table
        (y ?t -table) ; position y of the robot

        (x_min) ; minimum position x of the room
        (y_min) ; minimum position y of the room
        (x_max) ; maximum position x of the room
        (y_max) ; maximum position y of the room

        (t_dim ?t -table) ; dimension of the table
        (holding ?r -robot) ; number of drinks holded by the robot

        ;function to control the processes to simulate durative actions
        (p_h_d_C ?d -drink ?t -table) ;prepare hot drink counter
        (p_c_d_C ?d -drink ?t -table) ;prepare cold drink counter
        (c_C ?r -robot ?t -table) ;cleaning counter
        (mf_C ?r -robot) ;moving fast counter
        (ms_C ?r -robot) ;moving slow counter
    )

    ;; to enable the robot to move at different speeds in a grid like environment we assume the time unit equal to 2 time unit of the planner
    ; barista actions
    (:action Hot_drink_Prepare
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (hot_drink ?d) (not (waiter ?r)) (bar ?t) (not (busy ?r)))
        :effect (and (p_h_d_F ?d ?t) (busy ?r))
    )    
    (:process Hot_drink_Preparing
        :parameters (?d -drink ?t -table)
        :precondition (p_h_d_F ?d ?t)
        :effect (increase (p_h_d_C ?d ?t) (* #t 1.0))
    )
    (:event Hot_drink_Prepared
        :parameters (?d -drink ?t -table)
        :precondition (and (p_h_d_F ?d ?t) (= (p_h_d_C ?d ?t) 10))
        :effect (and (drink_on_table ?d ?t) (not (busy ?r)) (assign (p_h_d_C ?d ?t) 0) (not (p_h_d_F ?d ?t)))
    )
    (:constraint Hot_drink_Preparing_duration
        :parameters (?d -drink ?t -table)
        :condition (<= (p_h_d_C ?d ?t) 10)
    )
    
    (:action Cold_drink_Prepare
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (cold_drink ?d) (not (waiter ?r)) (bar ?t) (not (busy ?r)))
        :effect (and (p_c_d_F ?d ?t) (busy ?r))
    )    
    (:process Cold_drink_Preparing
        :parameters (?d -drink ?t -table)
        :precondition (p_c_d_F ?d ?t)
        :effect (increase (p_c_d_C ?d ?t) (* #t 1.0))
    )
    (:event Cold_drink_Prepared
        :parameters (?d -drink ?t -table)
        :precondition (and (p_c_d_F ?d ?t) (= (p_c_d_C ?d ?t) 6))
        :effect (and (drink_on_table ?d ?t) (not (busy ?r)) (assign (p_c_d_C ?d ?t) 0) (not (p_c_d_F ?d ?t)))
    )
    (:constraint Cold_drink_Preparing_duration
        :parameters (?d -drink ?t -table)
        :condition (<= (p_c_d_C ?d ?t) 6)
    )
    
    ; drink serving and cleaning
    (:action Clean_init
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (not (holding_tray ?r)) (= (holding ?r) 0) (not (clean ?t)) (not (busy ?r)))
        :effect (and (c_F ?r ?t) (busy ?r))
    )    
    (:process Cleaning
        :parameters (?r -robot ?t -table)
        :precondition (c_F ?r ?t)
        :effect (increase (c_C ?r ?t) (* #t 1.0))
    )
    (:event Cleaned
        :parameters (?r -robot ?t -table)
        :precondition (and (c_F ?r ?t) (= (c_C ?r ?t) (* (t_dim ?t) 4 )))
        :effect (and (clean ?t) (not (busy ?r)) (assign (c_C ?r ?t) 0) (not (c_F ?r ?t)))
    )
    (:constraint Cleaning_duration
        :parameters (?r -robot ?t -table)
        :condition (<= (p_c_d_C ?r ?t) (* (t_dim ?t) 4 ))
    )
    
    (:event Drink_served
        :parameters (?d -drink ?t -table)
        :precondition (drink_on_table ?d ?t)
        :effect (and (served ?d ?t)) ; logically it should go also (not (clean ?t)) just to say that if i put a drink on the table then i will need to clean it
    )    

    ; pick-up, put-down drinks actions module
    (:action Pick_up_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t) (not (busy ?r)))
        :effect (and (increase (holding ?r) 1) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    ;control
    (:action Put_down_drink
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (drink_holded ?d ?r) (not (busy ?r)))
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t))
    )
    ;control
    (:action Pick_up_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0) (not (busy ?r)))
        :effect (holding_tray ?r)
    )
    ;control
    (:action Put_down_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (bar ?t) (holding_tray ?r) (= (holding ?r) 0) (not (busy ?r)))
        :effect (not (holding_tray ?r))
    )


    ; moving actions module

    ;if the robot is not holding the tray it can move at 2 m/tu
    (:action Move_up_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (y_max) (+ (y ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )    
    (:process Moving_fast
        :parameters (?r -robot)
        :precondition (mf_F ?r)
        :effect (increase (mf_C ?r) (* #t 1.0))
    )
    (:event Moved_up_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?r) (= (mf_C ?r) 1))
        :effect (and (increase (y ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )
    (:constraint Moving_fast_duration
        :parameters (?r -robot)
        :condition (<= (mf_C ?r) 1)
    )

    (:action Move_down_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (y_min) (- (y ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )
    (:event Moved_down_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?r) (= (mf_C ?r) 1))
        :effect (and (decrease (y ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )   
    
    (:action Move_left_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (x_min) (- (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )
    (:event Moved_left_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?r) (= (mf_C ?r) 1))
        :effect (and (decrease (x ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )   
    
    (:action Move_right_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (x_max) (+ (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )
    (:event Moved_right_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?r) (= (mf_C ?r) 1))
        :effect (and (increase (x ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )  
    
    (:action Move_up_right_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (y_max) (+ (y ?r) 1)) (>= (x_max) (+ (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )
    (:event Moved_up_right_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?d) (= (mf_C ?r) 1))
        :effect (and (increase (y ?r) 1) (increase (x ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )  

    (:action Move_up_left_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (y_max) (+ (y ?r) 1)) (>= (x_min) (- (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )
    (:event Moved_up_left_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?r) (= (mf_C ?r) 1))
        :effect (and (increase (y ?r) 1) (decrease (x ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )  

    (:action Move_down_right_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (y_min) (- (y ?r) 1)) (>= (x_max) (+ (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )
    (:event Moved_down_right_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?r) (= (mf_C ?r) 1))
        :effect (and (decrease (y ?r) 1) (increase (x ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )  

    (:action Move_down_left_fast_init
        :parameters (?r -robot)
        :precondition (and (>= (y_min) (- (y ?r) 1)) (>= (x_min) (- (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (mf_F ?r) (busy ?r))
    )
    (:event Moved_down_left_fast
        :parameters (?r -robot)
        :precondition (and (mf_F ?r) (= (mf_C ?r) 1))
        :effect (and (decrease (y ?r) 1) (decrease (x ?r) 1) (not (busy ?r)) (assign (mf_C ?r) 0) (not (mf_F ?r)))
    )  

    ; if the robot is holding the tray it can move at 1 m/tu
    (:action Move_up_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (y_max) (+ (y ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )    
    (:process Moving_slow
        :parameters (?r -robot)
        :precondition (ms_F ?r)
        :effect (increase (ms_C ?r) (* #t 1.0))
    )
    (:event Moved_up_slow
        :parameters (?r -robot)
        :precondition (and (ms_F ?r) (= (ms_C ?r) 2))
        :effect (and (increase (y ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )
    (:constraint Moving_slow_duration
        :parameters (?r -robot)
        :condition (<= (ms_C ?r) 2)
    )
    
    (:action Move_down_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (y_min) (- (y ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )
    (:event Moved_down_slow
        :parameters (?r -robot)
        :precondition (and (ms_F ?r) (= (ms_C ?r) 2))
        :effect (and (decrease (y ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )   
    
    (:action Move_left_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (x_min) (- (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )
    (:event Moved_left_slow
        :parameters (?r -robot)
        :precondition (and (ms_F ?r) (= (ms_C ?r) 2))
        :effect (and (decrease (x ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )   
    
    (:action Move_right_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (x_max) (+ (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )
    (:event Moved_right_slow
        :parameters (?r -robot)
        :precondition (and (ms_F ?r) (= (ms_C ?r) 2))
        :effect (and (increase (x ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )  
    
    (:action Move_up_right_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (y_max) (+ (y ?r) 1)) (>= (x_max) (+ (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )
    (:event Moved_up_right_slow
        :parameters (?r -robot)
        :precondition (and (ms_F ?d) (= (ms_C ?r) 2))
        :effect (and (increase (y ?r) 1) (increase (x ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )  

    (:action Move_up_left_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (y_max) (+ (y ?r) 1)) (>= (x_min) (- (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )
    (:event Moved_up_left_slow
        :parameters (?r -robot)
        :precondition (and (ms_F ?r) (= (ms_C ?r) 2))
        :effect (and (increase (y ?r) 1) (decrease (x ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )  

    (:action Move_down_right_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (y_min) (- (y ?r) 1)) (>= (x_max) (+ (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )
    (:event Moved_down_right_slow
        :parameters (?r -robot)
        :precondition (and (ms_F ?r) (= (ms_C ?r) 2))
        :effect (and (decrease (y ?r) 1) (increase (x ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )  

    (:action Move_down_left_slow_init
        :parameters (?r -robot)
        :precondition (and (>= (y_min) (- (y ?r) 1)) (>= (x_min) (- (x ?r) 1)) (not (holding_tray ?r)) (not (busy ?r)))
        :effect (and (ms_F ?r) (busy ?r))
    )
    (:event Moved_down_slow_fast
        :parameters (?r -robot)
        :precondition (and (ms_F ?r) (= (ms_C ?r) 2))
        :effect (and (decrease (y ?r) 1) (decrease (x ?r) 1) (not (busy ?r)) (assign (ms_C ?r) 0) (not (ms_F ?r)))
    )  
)