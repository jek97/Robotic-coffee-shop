;Luca Sortino, Bauyrzhan Zhakanov, Giacomo Lugano (jek.lugano@yahoo.com)
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
        (hot_drink ?d -drink) ; T is an hot drink, F if is a cold one
        (drink_n ?d -drink) ; to pass the information of which drink we're preparing in the prepare drink between action and event

        ; (biscuit_n ?bis - biscuit)
        (biscuit_deliver ?bis - biscuit) ; T 

        (waiter ?r -robot) ; T if the robot is a waiter, F if is a barista
        (holding_tray ?r -robot) ; T if the robot r is holding a tray

        (bar ?t -table) ; T if the table is the bar
        (clean ?t -table) ; T if the table is clean

        (drink_on_table ?d -drink ?t -table) ; T if the drink d is on the table t
        (drink_holded ?d -drink ?r -robot) ; T if the drink d is holded by the robot r gripper

        (biscuit_on_table ?bis -biscuit ?t -table) ; T if the biscuit d is on the table t
        (biscuit_holded ?bis -biscuit ?r -robot)

        (robot_pos ?r -robot ?t -table) ; robot position, thet table at which the robot is
        (to ?t -table) ; destination table of the action move
    )    


    (:functions 
        (dist ?t -table ?t -table) ; distance between two tables
        (tim ?r -robot) ; value of the timer
        (t_dim ?t -table) ; dimension of the table
        (holding ?r -robot) ; number of drinks and biscuits holded by the robot
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


    (:action Hot_drink_Prepare ; initial action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (hot_drink ?d) (not (waiter ?r)) (robot_pos ?r ?t) (bar ?t) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 0) (drink_n ?d))
    )    
    (:event Hot_drink_Prepared ; event to conclude the action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (and (>= (tim ?r) 10) (<= (tim ?r) 20))  (drink_n ?d) (robot_pos ?r ?t) (bar ?t))
        :effect (and (drink_on_table ?d ?t) (assign (tim ?r) 150) (not (drink_n ?d)))
    )

    (:action Cold_drink_Prepare ; initial action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (not (hot_drink ?d)) (not (waiter ?r)) (robot_pos ?r ?t) (bar ?t) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 21) (drink_n ?d))
    )    
    (:event Cold_drink_Prepared ; event to conclude the action
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (and (>= (tim ?r) 27) (<= (tim ?r) 37)) (drink_n ?d) (robot_pos ?r ?t) (bar ?t))
        :effect (and (drink_on_table ?d ?t) (assign (tim ?r) 150) (not (drink_n ?d)))
    )

    ; (:action Biscuit ; initial action
    ;     :parameters (?bis -biscuit ?r -robot ?t -table)
    ;     :precondition (and (biscuit_n ?bis) (not (waiter ?r)) (robot_pos ?r ?t) (bar ?t) (>= (tim ?r) 100))
    ;     :effect (and (assign (tim ?r) 0) (biscuit_n ?bis))
    ; )    
    ; (:event Biscuit_Prepared ; event to conclude the action
    ;     :parameters (?bis -biscuit ?r -robot ?t -table)
    ;     :precondition (and (= (tim ?r) 10) (biscuit_n ?bis) (robot_pos ?r ?t) (bar ?t))
    ;     :effect (and (biscuit_on_table ?bis ?t) (assign (tim ?r) 150) (not (biscuit_n ?bis)))
    ; )
    
    ; move actions    
    (:action Move_slow
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t1) (holding_tray ?r) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 38) (to ?t2))
    )  
    (:event Moved_slow
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (and (>= (tim ?r) (+ (* (dist ?t1 ?t2) 2) 38)) (<= (tim ?r) (+ (* (dist ?t1 ?t2) 2) 48))) (to ?t2) (robot_pos ?r ?t1))
        :effect (and (robot_pos ?r ?t2) (not (to ?t2)) (not (robot_pos ?r ?t1)) (assign (tim ?r) 150))
    )

    (:action Move_fast
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t1) (not (holding_tray ?r)) (>= (tim ?r) 100))
        :effect (and (assign (tim ?r) 53) (to ?t2))
    )  
    (:event Moved_fast
        :parameters (?t1 -table ?r -robot ?t2 -table)
        :precondition (and (and (>= (tim ?r) (+ (dist ?t1 ?t2) 53)) (<= (tim ?r) (+ (dist ?t1 ?t2) 63))) (to ?t2) (robot_pos ?r ?t1))
        :effect (and (robot_pos ?r ?t2) (not (to ?t2)) (not (robot_pos ?r ?t1)) (assign (tim ?r) 150))
    )

    ; DRINKSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
    ; pick-up, put-down drinks 
    (:action Pick_up_drink
        :parameters (?d -drink ?r -robot ?t -table)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (or (and (not (holding_tray ?r)) (= (holding ?r ) 0)) (and (holding_tray ?r) (< (holding ?r) 3))) (drink_on_table ?d ?t) (>= (tim ?r) 100))
        :effect (and (increase (holding ?r) 1) (drink_holded ?d ?r) (not (drink_on_table ?d ?t)))
    ) 
    
    (:action Put_down_drink
        :parameters (?r -robot ?t -table ?d -drink ?bis -biscuit)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (drink_holded ?d ?r) (>= (tim ?r) 100))
        :effect (and (decrease (holding ?r) 1) (not (drink_holded ?d ?r)) (drink_on_table ?d ?t) (biscuit_deliver ?bis))
    )

    ; BISCUITSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
    ;; Pick up a biscuit from the bar counter
    (:action Pick_up_biscuit
        :parameters (?bis -biscuit ?r -robot ?t1 -table ?t2 -table ?d -drink)
        :precondition (and 
            (waiter ?r) 
            (robot_pos ?r ?t1) 
            (bar ?t1)
            (not (hot_drink ?d))
            (or 
                (and (not (holding_tray ?r)) (= (holding ?r) 0)) 
                (and (holding_tray ?r))
            ) 
            (biscuit_deliver ?bis) 
            ; (biscuit_on_table ?bis ?t) 
            (>= (tim ?r) 100)
        )
        :effect (and 
            (when (and (drink_on_table ?d ?t2) (not (bar ?t2)))
                (and 
                    (increase (holding ?r) 1) 
                    (biscuit_holded ?bis ?r) 
                    ; (biscuit_on_table ?bis ?t2)
                )
            )
            (when (not (drink_on_table ?d ?t2))
                (and 
                    (decrease (holding ?r) 1) 
                    (not (biscuit_holded ?bis ?r))
                    ; (not (biscuit_on_table ?bis ?t2))
                )
            )
        )
    )

    (:action Put_down_biscuit
        :parameters (?r -robot ?t -table ?bis -biscuit)
        :precondition (and (waiter ?r) (robot_pos ?r ?t) (biscuit_holded ?bis ?r) (>= (tim ?r) 100))
        :effect (and (decrease (holding ?r) 1) (not (biscuit_holded ?bis ?r)) (biscuit_on_table ?bis ?t))
    )
    
    ; TRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY
    ;; Pick up and put down tray
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
        :precondition (and (robot_pos ?r ?t) (and (>= (tim ?r) (+ (* (t_dim ?t) 4) 66)) (<= (tim ?r) (+ (* (t_dim ?t) 4) 76))))
        :effect (and (clean ?t) (assign (tim ?r) 150))
    )
)