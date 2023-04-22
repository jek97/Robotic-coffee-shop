;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano

(define (domain coffee_robot)

;remove requirements that are not needed
    (:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effects :negative-preconditions :duration-inequalities :equality)

    (:types ;todo: enumerate types and their hierarchy here, e.g. car truck bus - vehicle
        drink 
        waiter
        barista
        table 
        bar 
        customer 
    )

    (:predicates ;todo: define predicates here
        (hot_drink ?d - drink) 
        (cold_drink ?d - drink)

        (barista ?r - robot)
        (Waiter ?r - robot)

        (table ?l - location)
        (bar ?l - location)

        (Customer_at_table ?c - property)
        (Table_cleaned ?l - location)

        (HDt ?l - property)
        (CDt ?l - property)

        (holding ?r - property)
        (holding_tray ?r - property)


        ;HDt: Hot drinks on the table x (property of the table) numerative 

        ;CDt: Cold drinks on the table x (property of the table) numerative 

        ;holding (a drink) numerative (number of drinks we’re holding) 

        ;holding tray 
    )


    (:functions ;todo: define numeric functions here
    )

    ;define actions here

    (:durative-action Prepare_Hot_drinks
        :Parameters (drink ?d) (robot ?r) (table ?t)
        :Duration (= ?duration 5)
        :Precondition (and (hot_drink ?d) (barista ?r) (bar ?t)) 
        :Effects (increase (Hdt ?t) (+ 1)) 
    )
    
    (:durative-action Prepare_Cold_drinks
        :Parameters (and (drink ?d) (robot ?r) (table ?t))
        :Duration (= ?duration 3)
        :Precondition (and (cold_drink ?d) (barista ?r) (bar ?t))
        :Effects (increase (Cdt ?t) (+ 1)) 
    )
    
    (:action Pick_up_hot_drink
        :Parameters: (and (drink ?d) (robot ?r) (table ?t))
        :Precondition: (and (waiter ?r) (at ?r ?t) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3)) (> HDt ?t  0)))
        :Effects: (and (increase (holding ?r) (+1)) (decrease (HDT ?t) 1))
    ) 
    
    (:action Pick_up_cold_drink
        :Parameters: (and (drink ?d) (robot ?r) (table ?t))
        :Precondition: (and (waiter ?r) (at ?r ?t) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3)) (> CDt ?t  0)))
        :Effects: (and (increase (holding ?r) (+1)) (decrease (CDT ?t) 1))
    )
    
    (:action Put_down_cold_drink
        :Parameters: (and (robot ?r) (table ?t))
        :Precondition: (and (waiter ?r) (at ?r ?t) (> (holding ?r) 0))
        :Effects: (and (decrease (holding ?r) (+1)) (increase (CDT ?t) 1))
    )
    
    (:action Put_down_hot_drink
        :Parameters: (and (robot ?r) (table ?t))
        :Precondition: (and (waiter ?r) (at ?r ?t) (> (holding ?r) 0))
        :Effects: (and (decrease (holding ?r) (+1)) (increase (HDT ?t) 1))
    ) 
    
    (:action Pick_up_tray
        :Parameters: (and  (robot ?r) (table ?t))
        :Precondition: (and (waiter ?r) (at ?r ?t) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0))
        :Effects: (holding_tray ?r)
    )
    
    (:action Put_down_tray
        :Parameters: (and (robot ?r) (table ?t))
        :Precondition: (and (waiter ?r) (at ?r ?t) (bar ?t) (holding_tray ?r) (= (holding ?r) 0))
        :Effects: (not (holding_tray ?r))
    ) 