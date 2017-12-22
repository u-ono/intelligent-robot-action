#include <ros/ros.h>
#include <image_transport/image_transport.h>
#include <cv_bridge/cv_bridge.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <geometry_msgs/Point.h>

class MyCvPkg
{
  image_transport::Subscriber img_sub_;
  image_transport::ImageTransport it_;
  ros::Publisher face_pub;
  geometry_msgs::Point pt;

  void imageCallback(const sensor_msgs::ImageConstPtr &msg)
  {
    ROS_INFO("Received image");
    cv::Mat in_img = cv_bridge::toCvCopy(msg, msg->encoding)->image;

    double scale = 4.0;
    cv::Mat gray, smallImg(cv::saturate_cast<int>(in_img.rows/scale), cv::saturate_cast<int>(in_img.cols/scale), CV_8UC1);
    cv::cvtColor(in_img, gray, CV_BGR2GRAY);
    cv::resize(gray, smallImg, smallImg.size(), 0, 0, cv::INTER_LINEAR);
    cv::equalizeHist(smallImg, smallImg);

    std::string cascadeName = "/usr/share/opencv/haarcascades/haarcascade_frontalface_alt.xml";
    cv::CascadeClassifier cascade;
    if(!cascade.load(cascadeName))
        std::cout << "error" << std::endl;
    std::vector<cv::Rect> faces;
    cascade.detectMultiScale(smallImg, faces, 1.1, 2, CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));

    cv::Point center;
    std::vector<cv::Rect>::const_iterator r = faces.begin();
    for(; r != faces.end(); ++r) {
        int radius;
        center.x = cv::saturate_cast<int>((r->x + r->width*0.5)*scale);
        center.y = cv::saturate_cast<int>((r->y + r->height*0.5)*scale);
        radius = cv::saturate_cast<int>((r->width + r->height)*0.25*scale);
        cv::circle(in_img, center, radius, cv::Scalar(80,80,255), 3, 8, 0);
    }

    cv::imshow("face_detection", in_img);
    cv::waitKey(1);

    pt.x = center.x;
    pt.y = center.y;
    face_pub.publish(pt);
  }

public:
  MyCvPkg(ros::NodeHandle nh = ros::NodeHandle()) : it_(nh), pt()
  {
    img_sub_ = it_.subscribe("image", 3, &MyCvPkg::imageCallback, this);
    face_pub = nh.advertise<geometry_msgs::Point>("face_point", 1);
    cv::namedWindow("face", 1);
  }
};

int main(int argc, char **argv)
{
  ros::init(argc, argv, "face_detection");
  //ros::NodeHandle n;
  MyCvPkg mcp;
  ros::spin();
}
