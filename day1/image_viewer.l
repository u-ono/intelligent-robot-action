#!/usr/bin/env roseus

(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "opencv_apps")
(ros::load-ros-manifest "image_view2")
(ros::load-ros-manifest "geometry_msgs")
;;import msgs

(ros::roseus "client_eus") ;;make client
(ros::advertise "/image_marker" image_view2::ImageMarker2 1) ;;


(defclass image_viewer
  :super propertied-object
  :slots ())
(defmethod image_viewer
  (:init () (ros::subscribe "/camshift/track_box" opencv_apps::RotatedRectStamped
			    #'send self :cb))
  (:cb (msg)
       (describe (send msg :rect))
       (setq marker (instance image_view2::ImageMarker2 :init))
       (send marker :type 0)
       (send marker :position (instance geometry_msgs::Point :init
					:x (send msg :rect :center :x)
					:y (send msg :rect :center :y)
					:z 0))
       (ros::publish "/image_marker" marker)))

       
(setq i (instance image_viewer :init))

(do-until-key
 (ros::spin-once)
 )

(ros::roseus "shutdown")
(exit)
