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

(setq *thing* nil)
(setq *face-point* nil)
(setq *hand* nil)
(setq *cliff* nil)

(defun cb-0 (msg)
  (setq *thing* msg)
  )

(defun cb-1 (msg)
  (setq *face-point* msg)
  )

(defun cb-2 (msg)
  (setq *hand* msg)
  )

(defun cb-cliff (msg)
  (setq *cliff* msg)
  )

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
	 (print "state is 0~%")
	 (if (get-thing *thing* *cliff*)
	     (setq *state* 1)
	   nil))
	(1
	 (print "state is 1~%")	 
	 (if (react-to-face *face-point* *cliff*)
	     (setq *state* 2)
	   nil))
	(2
	 (print "state is 2~%")	 
	 (if (hand-thing *hand*)
	     (setq *state* 3)
	   nil))
	(3
	 (print "state is 3~%")
	 ;;TODO
	 )
	(4
	 (exit)
	 )
	)
  )

;;(defvar *topic-thing* "/camera/depth_registered/boxesryokuball")
(defvar *topic-thing* "/camera/depth_registered/boxeshoujicha")
(defvar *topic-hand* "/camera/depth_registered/boxeshoujicha")
(defvar *topic-face* "/face_point")

(ros::subscribe "/mobie_base/events/cliff" kobuki_msgs::CliffEvent #'cb-cliff 1)
(ros::subscribe *topic-thing* jsk_recognition_msgs::BoundingBoxArray #'cb-0 1)
(ros::subscribe *topic-face* geometry_msgs::Point #'cb-1 1)
(ros::subscribe *topic-hand* jsk_recognition_msgs::BoundingBoxArray #'cb-2 1)

(do-until-key
 (ros::spin-once)
 (unix::usleep 1000000)
 (main)
 )
