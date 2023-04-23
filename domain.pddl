;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano
; type of planner s gbfs -ties smaller_g and -h haddabs (same as Ijcai 2018)

(define (domain coffee_robot)

;remove requirements that are not needed
    ;(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effect :negative-preconditions :duration-inequalities :equality)

    (:types ;enumerate types and their hierarchy here, e.g. car truck bus - vehicle
        drink -object
        robot -object
        table -location
        bound -location  
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

    )


    (:functions ;define numeric functions here
        (x ?r -robot) ; position x of the robot (needed only for the waiter)
        (y ?r -robot) ; position y of the robot (needed only for the waiter)

        (x ?t -table) ; position x of the table
        (y ?t -table) ; position y of the robot

        (x_min ?b -bound) ; minimum position x of the room
        (y_min ?b -bound) ; minimum position y of the room
        (x_max ?b -bound) ; maximum position x of the room
        (y_max ?b -bound) ; maximum position y of the room

        (t_dim ?t -table) ; dimension of the table
        (holding ?r -robot) ; number of drinks holded by the robot
    )

    ;; to enable the robot to move at different speeds in a grid like environment we assume the time unit equal to 2 time unit of the planner
    ; barista actions
    (:durative-action Prepare_Hot_drinks
        :parameters (?d -drink ?r -robot ?t -table)
        :duration (= ?duration 10)
        :condition (over all (and (hot_drink ?d) (not (waiter ?r)) (bar ?t))) 
        :effect (at end (drink_on_table ?d ?t)) 
    )
    
    (:durative-action Prepare_Cold_drinks
        :parameters (?d -drink ?r -robot ?t -table)
        :duration (= ?duration 6)
        :condition (over all (and (cold_drink ?d) (not (waiter ?r)) (bar ?t)))
        :effect (at end (drink_on_table ?d ?t))
    )
    
    ; drink serving and cleaning
    (:durative-action Clean
        :parameters (?r -robot ?t -table)
        :duration (= ?duration (* (t_dim ?t) 4 ))
        :condition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (not (holding_tray ?r)) (= (holding ?r) 0) (not (clean ?t)))
        :effect (clean ?t)
    )
    
    (:event Drink_served
        :parameters (?d -drink ?t -table)
        :precondition (drink_on_table ?d ?t)
        :effect (and (served ?d ?t)) ; logically it should go also (not (clean ?t)) just to say that if i put a drink on the table then i will need to clean it
    )    

    ; pick-up, put-down drinks actions module
    (:action Pick_up_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t))
        :effect (and (increase (holding ?r) (+1)) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    ;control
    (:action Put_down_drink
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (drink_holded ?d ?r))
        :effect (and (decrease (holding ?r) (+1)) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t))
    )
    ;control
    (:action Pick_up_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0))
        :effect (holding_tray ?r)
    )
    ;control
    (:action Put_down_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (x ?r) (x ?t)) (= (y ?r) (y ?t)) (bar ?t) (holding_tray ?r) (= (holding ?r) 0))
        :effect (not (holding_tray ?r))
    )


    ; moving actions module

    ;if the robot is not holding the tray it can move at 2 m/tu
    (:durative-action Move_up_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (y_max ?b) (+ (y ?r) 1)) (not (holding_tray ?r)))
        :effect (increase (y ?r) 1)
    )
    
    (:durative-action Move_down_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (y_min ?b) (- (y ?r) 1)) (not (holding_tray ?r)))
        :effect (decrease (y ?r) 1)
    )
    
    (:durative-action Move_left_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (x_min ?b) (- (x ?r) 1)) (not (holding_tray ?r)))
        :effect (decrease (x ?r) 1)
    )
    
    (:durative-action Move_right_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (x_max ?b) (+ (x ?r) 1)) (not (holding_tray ?r)))
        :effect (increase (x ?r) 1)
    )

    (:durative-action Move_up_right_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (y_max ?b) (+ (y ?r) 1)) (>= (x_max ?b) (+ (x ?r) 1)) (not (holding_tray ?r)))
        :effect (and (increase (y ?r) 1) (increase (x ?r) 1))
    )

    (:durative-action Move_up_left_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (y_max ?b) (+ (y ?r) 1)) (>= (x_min ?b) (- (x ?r) 1)) (not (holding_tray ?r)))
        :effect (and (increase (y ?r) 1) (decrease (x ?r) 1))
    )

    (:durative-action Move_down_right_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (y_min ?b) (- (y ?r) 1)) (>= (x_max ?b) (+ (x ?r) 1)) (not (holding_tray ?r)))
        :effect (and (decrease (y ?r) 1) (increase (x ?r) 1))
    )

    (:durative-action Move_down_left_fast
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 1)
        :condition (and (>= (y_min ?b) (- (y ?r) 1)) (>= (x_min ?b) (- (x ?r) 1)) (not (holding_tray ?r)))
        :effect (and (decrease (y ?r) 1) (decrease (x ?r) 1))
    )
    ; if the robot is holding the tray it can move at 1 m/tu
    (:durative-action Move_up_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (y_max ?b) (+ (y ?r) 1)) (holding_tray ?r))
        :effect (increase (y ?r) 1)
    )
    
    (:durative-action Move_down_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (y_min ?b) (- (y ?r) 1)) (holding_tray ?r))
        :effect (decrease (y ?r) 1)
    )
    
    (:durative-action Move_left_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (x_min ?b) (- (x ?r) 1)) (holding_tray ?r))
        :effect (decrease (x ?r) 1)
    )
    
    (:durative-action Move_right_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (x_max ?b) (+ (x ?r) 1)) (holding_tray ?r))
        :effect (increase (x ?r) 1)
    )

    (:durative-action Move_up_right_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (y_max ?b) (+ (y ?r) 1)) (>= (x_max ?b) (+ (x ?r) 1)) (holding_tray ?r))
        :effect (and (increase (y ?r) 1) (increase (x ?r) 1))
    )

    (:durative-action Move_up_left_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (y_max ?b) (+ (y ?r) 1)) (>= (x_min ?b) (- (x ?r) 1)) (holding_tray ?r))
        :effect (and (increase (y ?r) 1) (decrease (x ?r) 1))
    )

    (:durative-action Move_down_right_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (y_min ?b) (- (y ?r) 1)) (>= (x_max ?b) (+ (x ?r) 1)) (holding_tray ?r))
        :effect (and (decrease (y ?r) 1) (increase (x ?r) 1))
    )

    (:durative-action Move_down_left_slow
        :parameters (?r -robot ?b -bound)
        :duration (= ?duration 2)
        :condition (and (>= (y_min ?b) (- (y ?r) 1)) (>= (x_min ?b) (- (x ?r) 1)) (holding_tray ?r))
        :effect (and (decrease (y ?r) 1) (decrease (x ?r) 1))
    )
)