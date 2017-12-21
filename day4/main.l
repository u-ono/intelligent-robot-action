#!/usr/bin/env roseus
(ros::load-ros-manifest "kobuki_msgs")
(ros::load-ros-manifest "geometry_msgs")
(ros::load-ros-manifest "jsk_recognition_msgs")

(ros::roseus "present")

(load "package://dxl_armed_turtlebot/euslisp/dxl-armed-turtlebot-interface.l")
(dxl-armed-turtlebot-init)

;;load other files
(load "get-thing.l")
(load "hand-thing.l")
(load "react-to-face.l")
(load "shake-hand.l")

;;global variables
(setq *thing* (instance jsk_recognition_msgs::BoundingBoxArray :init))
(setq *face-point* (instance geometry_msgs::Point :init))
(setq *hand* (instance jsk_recognition_msgs::BoundingBoxArray :init))
(setq *bumper* (instance kobuki_msgs::BumperEvent :init))

;;callback functions for each message
(defun cb-0 (msg)
  (setq *thing* msg)
  )

(defun cb-1 (msg)
  (setq *face-point* msg)
  )

(defun cb-bumper (msg)
  (setq *bumper* msg)
  )

;;initialize state
(setq *state* 0)
#|
state
0 search and catch thing
1 detect human face and approach
2 hand thing
3 shaking hands
4 finish
|#

(defun main ()
  (case *state*
	(0
	 (print "state is 0")
	 (if (get-thing *thing*)
	     (setq *state* 1)
	   nil))
	(1
	 (print "state is 1")
	 (if (react-to-face *face-point* *bumper*)
	     (setq *state* 2)
	   nil))
	(2
	 (print "state is 2")	 
	 (if (hand-thing)
	     (setq *state* 3)
	   nil))
	(3
	 (print "state is 3")
	 (if (shake-hand)
	     (setq *state* 4)
	   nil)
	 )
	(4
	 (print "all finished")
	 )
	(t
	 )
	)
  )

;;topic
(defvar *topic-thing* "/camera/depth_registered/boxesryokuball")
(defvar *topic-face* "/face_point")
(defvar *topic-bumper* "/mobile_base/events/bumper")

;;subscribers
(ros::subscribe *topic-bumper* kobuki_msgs::BumperEvent #'cb-bumper)
(ros::subscribe *topic-thing* jsk_recognition_msgs::BoundingBoxArray #'cb-0)
(ros::subscribe *topic-face* geometry_msgs::Point #'cb-1)

;;initialize pose
(send *dxl-armed-turtlebot* :tuckarm-pose3)
(send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector))
(send *ri* :wait-interpolation)

(do-until-key
 (ros::spin-once)
 (unix::usleep 100000)
 (main)
 (unix::usleep 1000000)
 )
