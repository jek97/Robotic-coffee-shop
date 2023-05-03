;Luca Sortino, bauyrzhan zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)
; command to launch the planner: java -jar ../ENHSP-Public-enhsp-20/enhsp-dist/enhsp.jar -o domain.pddl -f ./instances/problem1.pddl
(define (domain coffee_robot)

    ;(:requirements :strips :fluents :durative-actions :timed-initial-literals :typing :conditional-effect :negative-preconditions :duration-inequalities :equality :time ::timed-effects)

    (:types
        drink -object
        biscuit -object
        robot -object
        table -location
    )

    (:predicates
        (drink_n ?d -drink) ; to pass the information of which drink we're preparing in the prepare drink between action and event

        (waiter ?r -robot) ; T if the robot is a waiter, F if is a barista
        (holding_tray ?r -robot) ; T if the robot r is holding a tray

        (bar ?t -table) ; T if the table is the bar
        (clean ?t -table) ; T if the table is clean
        (drink_on_table ?d -drink ?t -table) ; T if the drink d is on the table t
        (drink_holded ?d -drink ?r -robot) ; T if the drink d is holded by the robot r
        (robot_pos ?r -robot ?t -table) ; robot position, thet table at which the robot is
        (to ?t -table) ; destination table of the action move

        (biscuit_on_table ?bis -biscuit ?t -table) ; T if the biscuit d is on the table t, initially true with t=bar
        (biscuit_holded ?bis -biscuit ?r -robot) ; T if the biscuit bis is holded by the robo r
        (biscuit_deliver ?bis -biscuit ?t -table) ; T if the related cold drink was delivered, so we can proceed to deliver the biscuit
    )


    (:functions 
        (dist ?t -table ?t -table) ; distance between two tables
        (tim ?r -robot) ; valeu of the timer
        (tim_c ?d -drink) ; valeu of the timer for the drink temperature
        (tim_t ?t -table) ; valeu of the timer for the consumption of all the drinks at a given table
        (t_dim ?t -table) ; dimension of the table
        (holding ?r -robot) ; number of drinks holded by the robot
    )

    ;; to enable the robot to move at different speeds in our problem we assume the time unit equal to 2 time unit of the planner
    ; timer: instead of creating a process for each durative action i create a unique timer for each robot, based on the valeu assigned by the action it will last for a different time and launch a different event
    ; in particular 0< t <=10 prepare_hot_drink, 21< t <=27 prepare_cold_drink, 38< t <=42 move_slow, 53< t <=55 move_fast, 66< t <=74 clean expressed in tu of the planner (considering the maximum time of each action of each action, the time unit we are considering = 2 tu of the planner) 
    ; we also use the timer valeu tim as a busy flag of the robot, so if tim > 100 the robot is not busy
    
    ; preparing drink actions
    (:process Timer
        :parameters (?r -robot)
        :precondition (< (tim ?r) 100)
        :effect (increase (tim ?r) (* #t 1.0))
    )

    (:action Drink_Prepare ; initial action
        :parameters (?r -robot ?d -drink ?t -table)
        :precondition (and (not (waiter ?r)) (robot_pos ?r ?t) (bar ?t) (>= (tim ?r) 100))
        :effect (and (when (= (tim_c ?d) 10) (and (assign (tim ?r) 0) (drink_n ?d))) (when (= (tim_c ?d) 0) (and (assign (tim ?r) 21) (drink_n ?d)))) 
    )    
    (:event Drink_Prepared ; event to conclude the action
        :parameters (?r -robot ?d -drink ?t -table)
        :precondition (and (or (and (= (tim_c ?d) 10) (>= (tim ?r) 10) (<= (tim ?r) 20)) (and (= (tim_c ?d) 0) (>= (tim ?r) 27) (<= (tim ?r) 37))) (drink_n ?d) (robot_pos ?r ?t) (bar ?t))
        :effect (and (drink_on_table ?d ?t) (assign (tim ?r) 150) (when (= (tim_c ?d) 10) (assign (tim_c ?d) 8)) (not (drink_n ?d)))
    )
    
    ; cooling down
    (:process Cooling_down
        :parameters (?d -drink)
        :precondition (and (<= (tim_c ?d) 8) (> (tim_c ?d) 0))
        :effect (decrease (tim_c ?d) (* #t 1.0))
    )
    
    ; move actions    
    (:action Move
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t1) (>= (tim ?r) 100))
        :effect (and (to ?t2) (when (holding_tray ?r) (assign (tim ?r) 38)) (when (not (holding_tray ?r)) (assign (tim ?r) 53)))
    )  
    (:event Moved
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (or (and (holding_tray ?r) (>= (tim ?r) (+ (* (dist ?t1 ?t2) 2) 38)) (<= (tim ?r) (+ (* (dist ?t1 ?t2) 2) 48))) (and (not (holding_tray ?r)) (>= (tim ?r) (+ (dist ?t1 ?t2) 53)) (<= (tim ?r) (+ (dist ?t1 ?t2) 63)))) (to ?t2) (robot_pos ?r ?t1))
        :effect (and (robot_pos ?r ?t2) (not (to ?t2)) (not (robot_pos ?r ?t1)) (assign (tim ?r) 150))
    )

    ; pick-up, put-down drinks and tray
    (:process Consuming_timer
        :parameters (?t -table)
        :precondition (and (<= (tim_t ?t) 8) (> (tim_t ?t) 0))
        :effect (decrease (tim_t ?t) (* #t 1.0))
    )

    (:action Pick_up_drink
        :parameters (?r -robot ?d -drink ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t) (>= (tim ?r) 100))
        :effect (and (increase (holding ?r) 1) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    
    (:action Put_down_drink
        :parameters (?r -robot ?d -drink ?t -table ?bis -biscuit)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (drink_holded ?d ?r) (>= (tim ?r) 100))
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t) (when (and (> (tim_c ?d) 0) (not (bar ?t))) (assign (tim_c ?d) 10)) (when (and (<= (tim_c ?d) 0) (not (bar ?t))) (biscuit_deliver ?bis ?t)) (decrease (tim_t ?t) 1))
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

    ;; Pick up a biscuit from the bar counter
    (:action Pick_up_biscuit
        :parameters (?r -robot ?bis -biscuit ?t -table ?t1 -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (bar ?t) (or (and (not (holding_tray ?r)) (= (holding ?r) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (>= (tim ?r) 100)
            (biscuit_deliver ?bis ?t1))
        :effect (and (increase (holding ?r) 1) (biscuit_holded ?bis ?r))
    )

    (:action Put_down_biscuit
        :parameters (?r -robot ?bis -biscuit ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (biscuit_holded ?bis ?r) (biscuit_deliver ?bis ?t) (>= (tim ?r) 100))
        :effect (and (decrease (holding ?r) 1) (not (biscuit_holded ?bis ?r)) (biscuit_on_table ?bis ?t) (not (biscuit_deliver ?bis ?t)) (decrease (tim_t ?t) 1))
    )

    ; cleaning
    (:action Clean
        :parameters (?r -robot ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (not (holding_tray ?r)) (= (holding ?r) 0) (not (clean ?t)) (= (tim_t ?t) 0))
        :effect (and (assign (tim ?r) 66))
    )    
    (:event Cleaned
        :parameters (?r -robot ?t -table)
        :precondition (and (robot_pos ?r ?t) (and (>= (tim ?r) (+ (* (t_dim ?t) 4) 66)) (<= (tim ?r) (+ (* (t_dim ?t) 4) 76))))
        :effect (and (clean ?t) (assign (tim ?r) 150))
    )  
    
)