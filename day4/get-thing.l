#!/usr/bin/env roseus

(defun get-thing (msg cliff)
  (cond
   ((or (null msg) (cliff))
    nil)
   ((equal (send cliff :state) 1)
    nil)
   ((msg)
    (let* ((bx-list (send msg :boxes));;boxarray
	   (b (car bx-list));;boxarrayの先頭
	   (dims (ros::tf-point->pos (send b :dimensions)))
	   (bx (make-cube (elt dims 0) (elt dims 1) (elt dims 2)))
	   (cam->obj-coords (ros::tf-pose->coords (send b :pose)))
	   (cam-coords (send (send *dxl-armed-turtlebot* :camera_rgb_optical_frame_lk) :copy-worldcoords))
	   (goal-coord) (pre-goal-coord) (x) (y) (z)
	   )
      ;;BoundingBoxArrayから物体の座標を計算する
      (send bx :newcoords (send cam-coords :transform cam->obj-coords))
      (send bx :worldcoords)
      (setq x (elt (send bx :pos) 0))
      (setq y (elt (send bx :pos) 1))
      (setq z (elt (send bx :pos) 2))
      ;;近ければ今回の物体として扱う
      (if (or (< x 700) (< y 700))
	  (progn
	    ;;物体に向き直す
	    (send *ri* :go-pos 0 0 (rad2deg (atan (/ y x))))
	    (send *ri* :wait-interpolation)
	    ;;遠ければ接近
	    (if (> (/ (norm (float-vector x y)) 1000) 0.3)
		(progn
		  (send *ri* :go-pos 0.1 0 0)
		  (send *ri* :wait-interpolation)
		  nil)
	      (progn
		;;つかむ準備
		(send *dxl-armed-turtlebot* :gripper :arm :angle-vector #f(50))
		(send *ri* :angle-vector (send *dxl-armed-turltebot* :angle-vector) 1000 :gripper-controller)
		(send *ri* :wait-interpolation :gripper-controller)
		
		(setq pre-goal-coord (make-cascoords :pos (float-vector 300 0 (+ 50 (elt (send bx :pos) 2))) :rpy #f(0 0 0)))
		(setq goal-coord (make-cascoords :pos (float-vector 300 0 (elt (send bx :pos) 2)) :rpy #f(0 0 0)))
		;;物体の近くにik
		(send *dxl-armed-turtlebot* :inversekinematics pre-goal-coord
		      :rotation-axis nil :debug-view nil)
		(send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000)
		(send *ri* :wait-interpolation)
		;;物体自体にik
		(send *dxl-armed-turtlebot* :inversekinematics goal-coord
		      :rotation-axis nil :debug-view nil)
		(send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000)
		(send *ri* :wait-interpolation)
		;;つかむ
		(send *ri* :start-grasp)
		(send *ri* :wait-interpolation :gripper-controller)
		;;持ち上げる
		(send *dxl-armed-turtlebot* :tuckarm-pose3)
		(send *ri* :wait-interpolation)
		;;tを返して次のstateに
		t)
	      )
	    )
	(progn
	  ;;回って探す
	  (send *ri* :go-pos 0 0 40)
	  (send *ri* :wait-interpolation)
	  (send *ri* :go-velocity 0 0 0)
	  (send *ri* :wait-interpolation)
	  nil)
	)
      )
    )
   (t
    (send *ri* :go-pos 0 0 60)
    (send *ri* :wait-interpolation)
    (send *ri* :go-velocity 0 0 0)
    (send *ri* :wait-interpolation)
    nil)
   )
  )
