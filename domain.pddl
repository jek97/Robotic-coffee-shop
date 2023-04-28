;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)
; command to launch the planner: java -jar ../ENHSP-Public-enhsp-20/enhsp-dist/enhsp.jar -o domain.pddl -f ./instances/problem1.pddl
(define (domain coffee_robot)

    ;(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effect :negative-preconditions :duration-inequalities :equality :time ::timed-effects)

    (:types
        drink -object
        robot -object
        table -location
    )

    (:predicates
        (hot_drink ?d -drink) ; T is an hot drink, F if is a cold one
        (drink_n ?d -drink) ; to pass the information of which drink we're preparing in the prepare drink between action and event

        (waiter ?r -robot) ; T if the robot is a waiter, F if is a barista
        (holding_tray ?r -robot) ; T if the robot r is holding a tray

        (bar ?t -table) ; T if the table is the bar
        (clean ?t -table) ; T if the table is clean
        (drink_on_table ?d -drink ?t -table) ; T if the drink d is on the table t
        (drink_holded ?d -drink ?r -robot) ; T if the drink d is holded by the robot r gripper
        (robot_pos ?r -robot ?t -table) ; robot position, thet table at which the robot is
        (to ?t -table) ; destination table of the action move
    )


    (:functions 
        (dist ?t -table ?t -table) ; distance between two tables
        (tim ?r -robot) ; valeu of the timer
        (t_dim ?t -table) ; dimension of the table
        (holding ?r -robot) ; number of drinks holded by the robot
    )

    ;; to enable the robot to move at different speeds in our problem we assume the time unit equal to 2 time unit of the planner
    ; timer: instead of creating a process for each durative action i create a unique timer for each robot, based on the valeu assigned by the action it will last for a different time and launch a different event
    ; in particular 0< t <=10 prepare_hot_drink, 11< t <=17 prepare_cold_drink, 18< t <=22 move_slow, 23< t <=25 move_fast, 26< t <=34 clean expressed in tu of the planner (considering the maximum time of each action of each action, the time unit we are considering = 2 tu of the planner) 
    ; we also use the timer valeu tim as a busy flag of the robot, so if tim > 100 the robot is not busy
    ; preparing drink actions
    (:process Timer
        :parameters (?r -robot)
        :precondition (< (tim ?r) 100)
        :effect (increase (tim ?r) (* #t 1.0))
    )


    (:action Hot_drink_Prepare ; initial action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (hot_drink ?d) (not (waiter ?r)) (robot_pos ?r ?t) (bar ?t) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 0) (drink_n ?d))
    )    
    (:event Hot_drink_Prepared ; event to conclude the action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (= (tim ?r) 10) (drink_n ?d) (robot_pos ?r ?t))
        :effect (and (drink_on_table ?d ?t) (assign (tim ?r) 150))
    )

    (:action Cold_drink_Prepare ; initial action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (not (hot_drink ?d)) (not (waiter ?r)) (robot_pos ?r ?t) (bar ?t) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 11) (drink_n ?d))
    )    
    (:event Cold_drink_Prepared ; event to conclude the action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (= (tim ?r) 17) (drink_n ?d) (robot_pos ?r ?t))
        :effect (and (drink_on_table ?d ?t) (assign (tim ?r) 150))
    )
    
    ; move actions
    (:action Move_slow
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t1) (not (holding_tray ?r)) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 18) (to ?t2))
    )  
    (:event Moved_slow
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (= (tim ?r) (+ (* (dist ?t1 ?t2) 2) 18)) (to ?t2) (robot_pos ?r ?t1))
        :effect (and (robot_pos ?r ?t2) (not (robot_pos ?r ?t1)) (assign (tim ?r) 150))
    )

    (:action Move_fast
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t1) (not (holding_tray ?r)) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 23) (to ?t2))
    )  
    (:event Moved_fast
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (= (tim ?r) (+ (dist ?t1 ?t2) 23)) (to ?t2) (robot_pos ?r ?t1))
        :effect (and (robot_pos ?r ?t2) (not (robot_pos ?r ?t1)) (assign (tim ?r) 150))
    )

    ; pick-up, put-down drinks and tray
    (:action Pick_up_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t) (>= (tim ?r) 100))
        :effect (and (increase (holding ?r) 1) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    
    (:action Put_down_drink
        :parameters (?r -robot ?t -table ?d -drink)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (drink_holded ?d ?r) (>= (tim ?r) 100))
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t))
    )
    
    (:action Pick_up_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (bar ?t) (not (holding_tray ?r)) (= (holding ?r) 0) (>= (tim ?r) 100))
        :effect (holding_tray ?r)
    )
    
    (:action Put_down_tray
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (bar ?t) (holding_tray ?r) (= (holding ?r) 0) (>= (tim ?r) 100))
        :effect (not (holding_tray ?r))
    )

    ; cleaning
    (:action Clean
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (not (holding_tray ?r)) (= (holding ?r) 0) (not (clean ?t)))
        :effect (and (assign (tim ?r) 26))
    )    
    (:event Cleaned
        :parameters (?r -robot ?t -table)
        :precondition (and (robot_pos ?r ?t) (= (tim ?r) (+ (* (t_dim ?t) 4) 26)))
        :effect (and (clean ?t) (assign (tim ?r) 150))
    )  
    
)