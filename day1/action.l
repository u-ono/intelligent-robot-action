#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")

(ros::roseus "action")

(load "package://turtleboteus/euslisp/turtlebot-interface.l")
(turtlebot-init)

(ros::rate 1)
(do-until-key
 (setq bs (send *ri* :state :bumper-vector))
 (if (v= bs (float-vector 0.0 0.0 0.0))
     (send *ri* :go-velocity 0.1 0 0)
     (send *ri* :go-velocity -0.1 0 40)
     )
 (ros::sleep)
 )



