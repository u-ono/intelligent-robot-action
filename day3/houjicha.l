#!/usr/bin/env roseus
(ros::load-ros-manifest "roseus")
(ros::roseus "houjicha")

;; jsk_pcl_rosのmsgを使うため、loadする
;;(ros::load-ros-manifest "jsk_pcl_ros")
(ros::load-ros-manifest "jsk_recognition_msgs")
; robotの初期化
(load "package://dxl_armed_turtlebot/euslisp/dxl-armed-turtlebot-interface.l")
(dxl-armed-turtlebot-init)

;; クラスタリング結果であるBoundingBoxのtopic名
;;(defvar *topic-name* "/camera/depth_registered/cluster_decomposer/boxes")
(defvar *topic-name* "/camera/depth_registered/boxes")
(defvar *bounding-box-list* nil)

;; コールバック関数
(defun bounding-box-array-cb (msg)
  (setq *bounding-box-list* (send msg :boxes)) ;; boxesは、BoundingBoxのArray(Euslispではlist)
  ;; BoundingBoxがあれば表示する
  (when (null (cdr *bounding-box-list*))
    (send *irtviewer* :draw-objects :flush nil)

      ;; BoundingBoxは、dimsntion(直方体の幅・奥行き・高さ)をもつ
    (let* ((b (car *bounding-box-list*))
	   (dims (ros::tf-point->pos (send b :dimensions)))
	   (bx (make-cube (elt dims 0) (elt dims 1) (elt dims 2)))
	   ;; (1) BoundingBoxのカメラ相対の座標系は、geometry_msgs/Poseという型で得られるので、Euslispのcoordsに変換する
	   (cam->obj-coords (ros::tf-pose->coords (send b :pose)))
	   ;; (2) *dxl-armed-turtlebot*モデルがカメラの座標系をもってるので、取得する
	   (cam-coords (send (send *dxl-armed-turtlebot* :camera_rgb_optical_frame_lk) :copy-worldcoords))
	   (goal-coord)
	   )
      ;; (3) Euslisp内部でのworld座標系の値にして、そこにmake-cubeの箱を設置する
      (send bx :newcoords (send cam-coords :transform cam->obj-coords))
      (send bx :worldcoords)
      (send bx :draw-on :flush nil :color #f(1 0 0)) ;; 描画
      (send *irtviewer* :viewer :viewsurface :flush)
      (describe (send bx :pos))
      (send *ri* :go-pos 0 0 (rad2deg (atan (/ (elt (send bx :pos) 1) (elt (send bx :pos) 0)))))
      (send *ri* :wait-interpolation)
      (send *ri* :go-pos (- (/ (norm (float-vector (elt (send bx :pos) 0) (elt (send bx :pos) 1))) 1000) 0.2) 0 0)
      (send *ri* :wait-interpolation)
      (send *ri* :go-velocity 0 0 0)
      (send *ri* :wait-interpolation)
      (send *ri* :stop-grasp)
      (send *ri* :wait-interpolation :gripper-controller)
      ;(send *dxl-armed-turtlebot* :gripper :arm :angle-vector #f(50))
      ;(send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000 :gripper-controller)
      ;(send *ri* :wait-interpolation :gripper-controller)
      (setq goal-coord (make-cascoords :pos (float-vector 200 0 (elt (send bx :pos) 2)) :rpy #f(0 0 0)))
      (send *dxl-armed-turtlebot* :inverse-kinematics goal-coord
	    :rotation-axis nil
	    :debug-view nil)
      (send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000)
      (send *ri* :wait-interpolation)
      (send *ri* :start-grasp)
      (send *ri* :wait-interpolation :gripper-controller)
      (send *dxl-armed-turtlebot* :reset-pose)
      (send *ri* :wait-interpolation)
      )
    )
  )

(ros::subscribe *topic-name* jsk_recognition_msgs::BoundingBoxArray #'bounding-box-array-cb 1)

(send *dxl-armed-turtlebot* :tuckarm-pose3)
(send *ri* :angle-vector (send *dxl-armed-turtlebot* :angle-vector) 1000)
(send *ri* :wait-interpolation)

(ros::rate 1)
(do-until-key
 (ros::spin-once)
 (ros::sleep)
 )
