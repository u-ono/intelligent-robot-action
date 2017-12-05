#!/usr/bin/env roseus

(ros::load-ros-manifest "kobuki_msgs")

(ros::roseus "present")

;;load other files
(load "get-thing.l")
(load "hand-thing.l")

(defun cb-0 (msg)
  (setq *thing* msg)
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
	 (if (get-thing *thing*)
	     (setq *state* 1)
	   nil))
	(1
	 )
	(2
	 (if (hand-thing *hand*)
	     (setq *state* 3)
	   nil))
	 )
	(3
	 )
	(4
	 (exit)
	 )
	)
  )

(defvar *topic-thing* "/camera/depth_registered/cluster_decomposerryokuball/boxes")
(defvar *topic-hand* "/camera/depth_registered/cluster_decomposerhoujicha/boxes")

(ros::subscribe "/mobie_base/events/cliff" kobuki_msgs::CliffEvent #'cb-cliff 1)
(ros::subscribe *topic-thing* jsk_recognition_msgs::BoundingBoxArray #'cb-0 1)
(ros::subscribe *topic-hand* jsk_recognition_msgs::BoundingBoxArray #'cb-2 1)

(do-until-key
 (ros::spin-once)
 (main)
 )
