#!/usr/bin/env roseus

(defun hand-thing (msg)
  (cond
   ((msg)
    (let* ((bx-list (send msg :boxes))
	   (b (car bx-list))
	   (dims (ros::tf-point->pos (send b :dimensions)))
	   (bx (make-cube (elt dims 0) (elt dims 1) (elt dims 2)))
	   (cam->obj-coords (ros::tf-pose->coords (send b :pose)))
	   (cam-coords (send (send *dxl-armed-turtlebot* :camera_rgb_optical_frame_lk) :copy-worldcoords))
	   (goal-coord) (x) (y) (z)
	   )
      ;;手の座標を計算
      (send bx :newcoords (send cam-coords :transform cam->obj-coords))
      (send bx :worldcoords)
      (setq x (elt (send bx :pos) 0))
      (setq y (elt (send bx :pos) 1))
      (setq z (elt (send bx :pos) 2))
      ;;近い時のみにik
      (if (or (< x 400) (< y 400))
	  (progn
	    ;;向き直す
	    (send *ri* :go-pos 0 0 (rad2deg (atan (/ y x))))
	    (send *ri* :wait-interpolation)
	    (send *ri* :go-velocity 0 0 0)
	    (send *ri* :wait-interpolation)
	    ;;ik
	    (setq goal-coord (make-cascoords :pos (float-vector 300 0 (elt (send bx :pos) 2)) :rpy #f(0 0 0)))
	    (send *dxl-armed-turtlebot* :inversekinematics goal-coord
		  :rotation-axis t :debug-view nil)
	    (send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000)
	    (send *ri* :wait-interpolation)
	    ;;物体を放す
	    (send *ri* :stop-grasp)
	    (send *ri* :wait-interpolation :gripper-controller)
	    ;;５秒待機
	    (unix::usleep 5000)
	    (send *dxl-armed-turtlebot* :reset-pose)
	    (send *ri* :wait-interpolation)
	    ;;次のstateへ
	    t)
	nil)
      )
    )
   nil)
  )
