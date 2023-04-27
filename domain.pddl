
;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)

(define (domain coffee_robot)

    (:requirements :fluents :durative-actions :typing :negative-preconditions :duration-inequalities :disjunctive-preconditions :time)
    (:types
        drink -object
        robot -object
        table -location
    )

    (:predicates
        (hot_drink ?d -drink) ; T is an hot drink
        (cold_drink ?d -drink) ; T is a cold drink
        (served_hot_drink ?d -drink ?t -table) ; T if the drink d has passed by the table t and at that time was hot
        (served_cold_drink ?d -drink ?t -table) ; T if the drink d has passed by the table t and at that time was cold

        (waiter ?r -robot) ; T if the robot is a waiter
        (barista ?r -robot) ; F if the robot is a barista
        (holding_tray ?r -robot) ; T if the robot r is holding a tray

        (bar ?t -table) ; T if the table is the bar
        (clean ?t -table) ; T if the table is clean
        (drink_on_table ?d -drink ?t -table) ; T if the drink d is on the table t
        (drink_holded ?d -drink ?r -robot) ; T if the drink d is holded by the robot r gripper
        (ready ?d -drink) ; T when the drink is just prepared
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
        (drink_temperature ?d -drink) ; cooling down drinks counter
    )

    ;; to enable the robot to move at different speeds in a grid like environment we assume the time unit equal to 2 time unit of the planner

    ; preparing drinks
    (:durative-action Prepare_hot_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :duration (= ? duration 10)
        :condition (over all (and (hot_drink ?d) (barista ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t)))
        :effect (at end (and (drink_on_table ?d ?t) (ready ?d)))
    )

    (:durative-action Prepare_cold_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :duration (= ? duration 6)
        :condition (over all (and (cold_drink ?d) (barista ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t)))
        :effect (at end (and (drink_on_table ?d ?t) (ready ?d)))
    )
    

    ; cleaning
    (:durative-action Cleaning
        :parameters (?r -robot ?t -table)
        :duration (= ? duration (* (t_dim ?t) 4 ))
        :condition (and 
            (at start (not (clean ?t)))
            (over all (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (not (holding_tray ?r)) (= (holding ?r) 0)))
            )
        :effect (at end (clean ?t))
    )
    

    ; pick-up, put-down drinks and tray
    (:action Pick_up_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t))
        :effect (and (increase (holding ?r) 1) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    
    (:action Put_down_cold_drink
        :parameters (?r -robot ?t -table ?d -drink)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (drink_holded ?d ?r) (cold_drink ?d))
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t) (served_cold_drink ?d ?t))
    )
    (:action Put_down_hot_drink
        :parameters (?r -robot ?t -table ?d -drink)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (drink_holded ?d ?r) (hot_drink ?d))
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t) (served_hot_drink ?d ?t))
    )
    
    (:action Pick_up_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0))
        :effect (holding_tray ?r)
    )
    
    (:action Put_down_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (= (xr ?r) (xt ?t)) (= (yr ?r) (yt ?t)) (bar ?t) (holding_tray ?r) (= (holding ?r) 0))
        :effect (not (holding_tray ?r))
    )

    ; drinks get cold:
    (:process drink_cool_down
        :parameters (?d -drink)
        :precondition (and (hot_drink ?d) (ready ?d))
        :effect (increase (drink_temperature ?d) (* #t 1.0))
    )
    (:event drink_got_cold
        :parameters (?d -drink)
        :precondition (and (>= (drink_temperature ?d) 8) (hot_drink ?d))
        :effect (and (cold_drink ?d) (not (hot_drink ?d)) (assign (drink_temperature ?d) 0))
    )
    
    
    ; space constraint
    ;(:constraint X_constraint
    ;    :parameters (?r -robot)
    ;    :condition (and (<= (xr ?r) x_max) (>= (xr ?r) x_min))
    ;) 
    ;(:constraint Y_constraint
    ;    :parameters (?r -robot)
    ;    :condition (and (<= (yr ?r) y_max) (>= (yr ?r) y_min))
    ;) 

    ; moving actions
    ;if the robot is not holding the tray it can move at 2 m/tu, that means under our time unit of 2 sec a velocity of 1 m/s
    (:durative-action Move_up_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (>= (y_max) (+ (yr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (increase (yr ?r) 1))
    )

    (:durative-action Move_down_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (<= (y_min) (- (yr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (decrease (yr ?r) 1))
    )
    
    (:durative-action Move_left_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (<= (x_min) (- (xr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (decrease (xr ?r) 1))
    )

    (:durative-action Move_right_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (>= (x_max) (+ (xr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (increase (xr ?r) 1))
    )

    (:durative-action Move_up_right_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (and (>= (y_max) (+ (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (increase (yr ?r) 1) (increase (xr ?r) 1)))
    )

    (:durative-action Move_up_left_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (and (>= (y_max) (+ (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (increase (yr ?r) 1) (decrease (xr ?r) 1)))
    )

    (:durative-action Move_down_right_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (and (<= (y_min) (- (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (decrease (yr ?r) 1) (increase (xr ?r) 1)))
    )

    (:durative-action Move_down_left_fast
        :parameters (?r -robot)
        :duration (= ? duration 1)
        :condition (and 
            (at start (and (<= (y_min) (- (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (decrease (yr ?r) 1) (decrease (xr ?r) 1)))
    )


    ;if the robot is holding the tray it can move at 1 m/tu, that means under our time unit of 2 sec a velocity of 0.5 m/s

    (:durative-action Move_up_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (>= (y_max) (+ (yr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (increase (yr ?r) 1))
    )

    (:durative-action Move_down_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (<= (y_min) (- (yr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (decrease (yr ?r) 1))
    )
    
    (:durative-action Move_left_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (<= (x_min) (- (xr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (decrease (xr ?r) 1))
    )

    (:durative-action Move_right_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (>= (x_max) (+ (xr ?r) 1)))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (increase (xr ?r) 1))
    )

    (:durative-action Move_up_right_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (and (>= (y_max) (+ (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (increase (yr ?r) 1) (increase (xr ?r) 1)))
    )

    (:durative-action Move_up_left_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (and (>= (y_max) (+ (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (increase (yr ?r) 1) (decrease (xr ?r) 1)))
    )

    (:durative-action Move_down_right_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (and (<= (y_min) (- (yr ?r) 1)) (>= (x_max) (+ (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (decrease (yr ?r) 1) (increase (xr ?r) 1)))
    )

    (:durative-action Move_down_left_slow
        :parameters (?r -robot)
        :duration (= ? duration 2)
        :condition (and 
            (at start (and (<= (y_min) (- (yr ?r) 1)) (<= (x_min) (- (xr ?r) 1))))
            (over all (and (waiter ?r) (not (holding_tray ?r))))
            )
        :effect (at end (and (decrease (yr ?r) 1) (decrease (xr ?r) 1)))
    )
)
