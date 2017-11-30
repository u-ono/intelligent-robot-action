#!/usr/bin/env python

import rospy
from kobuki_msgs.msg import Sound

pub = rospy.Publisher('/mobile_base/commands/sound', Sound)
rospy.init_node('publish-sound')

while not rospy.is_shutdown():
    msg = Sound()
    rospy.loginfo(msg)
    msg.value = 6
    pub.publish(msg)
    rospy.sleep(1.0)
