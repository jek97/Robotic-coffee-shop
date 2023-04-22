;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano

(define (domain coffee_robot)

;remove requirements that are not needed
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effect :negative-preconditions :duration-inequalities :equality)

    (:types ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
        drink -object
        robot -object
        table -location 
        bound -location 
        customer 
    )

    (:predicates ;todo: define predicates here
        (hot_drink ?d -drink) 
        (cold_drink ?d -drink)
        (served ?d -drink)

        (barista ?r -robot)
        (Waiter ?r -robot)
        (holding_tray ?r -robot)

        (bar ?t -table)
        (cleaned ?t -table)


        ; to check
        (Customer_at_table ?c - property)
    )


    (:functions ;todo: define numeric functions here
        (x ?r -robot)
        (y ?r -robot)

        (x ?t -table)
        (y ?t -table)

        (x_min ?t -table)
        (y_min ?t -table)
        (x_max ?t -table)
        (y_max ?t -table)

        (t_dim ?t)
        (holding ?r -robot)
        (HDt ?l - property)
        (CDt ?l - property)
    )

    ;define actions here
    ;control
    (:durative-action Prepare_Hot_drinks
        :parameters (?d -drink) (?r -robot) (?t -table)
        :duration (= ?duration 5)
        :precondition (and (hot_drink ?d) (barista ?r) (bar ?t)) 
        :effect (increase (Hdt ?t) (+ 1)) 
    )
    ;control
    (:durative-action Prepare_Cold_drinks
        :parameters (?d -drink) (?r -robot) (?t -table)
        :duration (= ?duration 3)
        :precondition (and (cold_drink ?d) (barista ?r) (bar ?t))
        :effect (increase (Cdt ?t) (+ 1)) 
    )
    ;control
    (:durative-action Clean
        :parameters (?r -robot) (?t -table)
        :duration (= ?duration (* (t_dim ?t) 2 ))
        :precondition (and (waiter ?r) (and (= (x ?r) (x ?t)) (= (y ?r) (y ?t))) (not (holding_tray ?r)) (= (holding ?r) 0) (= (HDT ?t) 0) (= (CDT ?t) 0))
        :effect (cleaned ?t)
    )
    ;control
    (:action Pick_up_hot_drink
        :parameters (?d -drink) (?r -robot) (?t -table)
        :precondition (and (waiter ?r) (and (= (x ?r) (x ?t)) (= (y ?r) (y ?t))) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3)) (> HDt ?t  0)))
        :effect (and (increase (holding ?r) (+1)) (decrease (HDT ?t) 1))
    ) 
    ;control
    (:action Pick_up_cold_drink
        :parameters (?d -drink) (?r -robot) (?t -table)
        :precondition (and (waiter ?r) (and (= (x ?r) (x ?t)) (= (y ?r) (y ?t))) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3)) (> CDt ?t  0)))
        :effect (and (increase (holding ?r) (+1)) (decrease (CDT ?t) 1))
    )
    ;control
    (:action Put_down_cold_drink
        :parameters (?r -robot) (?t -table)
        :precondition (and (waiter ?r) (and (= (x ?r) (x ?t)) (= (y ?r) (y ?t))) (> (holding ?r) 0))
        :effect (and (decrease (holding ?r) (+1)) (increase (CDT ?t) 1))
    )
    ;control
    (:action Put_down_hot_drink
        :parameters (?r -robot) (?t -table)
        :precondition (and (waiter ?r) (and (= (x ?r) (x ?t)) (= (y ?r) (y ?t))) (> (holding ?r) 0))
        :effect (and (decrease (holding ?r) (+1)) (increase (HDT ?t) 1))
    ) 
    ;control
    (:action Pick_up_tray
        :parameters (?r -robot) (?t -table)
        :precondition (and (waiter ?r) (and (= (x ?r) (x ?t)) (= (y ?r) (y ?t))) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0))
        :effect (holding_tray ?r)
    )
    ;control
    (:action Put_down_tray
        :parameters (?r -robot) (?t -table)
        :precondition (and (waiter ?r) (and (= (x ?r) (x ?t)) (= (y ?r) (y ?t))) (bar ?t) (holding_tray ?r) (= (holding ?r) 0))
        :effect (not (holding_tray ?r))
    )
    ;good
    (:action Move_up
        :parameters (?r -robot) (?b -bound)
        :precondition (>= (y_max ?t) (+ (y ?r -robot) 1))
        :effect (increase (y ?r) 1)
    )
    ;good
    (:action Move_down
        :parameters (?r -robot) (?b -bound)
        :precondition (>= (y_min ?t) (- (y ?r -robot) 1))
        :effect (decrease (y ?r) 1)
    )
    ;good
    (:action Move_left
        :parameters (?r -robot) (?b -bound)
        :precondition (>= (x_min ?t) (- (x ?r -robot) 1))
        :effect (decrease (x ?r) 1)
    )
    ;good
    (:action Move_right
        :parameters (?r -robot) (?b -bound)
        :precondition (>= (x_max ?t) (+ (x ?r -robot) 1))
        :effect (increase (x ?r) 1)
    )

    (:event Served_drink
        :parameters (?d -drink) (?t -table)
        :precondition (and (not (bar ?t)) (or (HDT))
            ; trigger condition
        )
        :effect (and
            ; discrete effect(s)
        )
    )
    
)
d_on_t ?d ?t