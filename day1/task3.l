#!/usr/bin/env roseus
(ros::load-ros-manifest "roseus")
(ros::roseus "action")

(load "package://turtleboteus/euslisp/turtlebot-interface.l")
(turtlebot-init)


(do-until-key
 (setq bs (send *ri* :state :bumper-vector))
 (cond
  ((v= bs #f(1.0 0.0 0.0))
   (dotimes (i 6000)
     (send *ri* :go-velocity -0.1 0 -60))
   )    
  ((v= bs #f(1.0 1.0 0.0))
   (dotimes (i 3000)
     (send *ri* :go-velocity -0.1 0 -30))
   )   
  ((v= bs #f(0.0 0.0 0.0)) (send *ri* :go-velocity 0.1 0 0))
  ((v= bs #f(0.0 1.0 0.0))
   (dotimes (i 9000)
     (send *ri* :go-velocity -0.1 0 -90))
   )
  ((v= bs #f(0.0 1.0 1.0))
   (dotimes (i 3000)
     (send *ri* :go-velocity -0.1 0 30))
   )
  ((v= bs #f(0.0 0.0 1.0))
   (dotimes (i 6000)
     (send *ri* :go-velocity -0.1 0 60)
   )
 )
