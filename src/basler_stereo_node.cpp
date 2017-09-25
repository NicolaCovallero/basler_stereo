#include "ros/ros.h"
#include "std_msgs/String.h"
#include "sensor_msgs/Image.h"
#include "/usr/local/include/stereovision/stereo.h"
#include <image_transport/image_transport.h>
#include <cv_bridge/cv_bridge.h>
#include <sensor_msgs/image_encodings.h>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <pcl_conversions/pcl_conversions.h>


#include <sstream>

cv_bridge::CvImagePtr img1,img2;

bool left,right;
ros::Time stamp_left,stamp_right;

void leftCameraCallback(const sensor_msgs::Image::Ptr & image_msg)
{
  ROS_DEBUG("Left Image received");
  img1 = cv_bridge::toCvCopy(image_msg, sensor_msgs::image_encodings::BGR8);
  cv::imwrite("left.png",img1->image);
  left = true;
  stamp_left = image_msg->header.stamp;
  return;
}

void rightCameraCallback(const sensor_msgs::Image::Ptr & image_msg)
{
  ROS_DEBUG("Right Image received");
  img2 = cv_bridge::toCvCopy(image_msg, sensor_msgs::image_encodings::BGR8);  
  cv::imwrite("right.png",img2->image);
  right = true;
  stamp_right = image_msg->header.stamp;
  return;
}

int main(int argc, char **argv)
{
  /**
   * The ros::init() function needs to see argc and argv so that it can perform
   * any ROS arguments and name remapping that were provided at the command line.
   * For programmatic remappings you can use a different version of init() which takes
   * remappings directly, but for most command-line programs, passing argc and argv is
   * the easiest way to do it.  The third argument to init() is the name of the node.
   *
   * You must call one of the versions of ros::init() before using any other
   * part of the ROS system.
   */
  ros::init(argc, argv, "stereo");

  ros::NodeHandle n;
  ros::Subscriber sub_l = n.subscribe("/stereo/left/image_raw", 1, leftCameraCallback);
  ros::Subscriber sub_r = n.subscribe("/stereo/right/image_raw", 1, rightCameraCallback);
  ros::Publisher pub_pcl = n.advertise<sensor_msgs::PointCloud2>("/stereo/pointcloud", 1000);
  
  sv::Stereo sv;
  sv.readInExParams("/home/nicola/iri_ws/src/basler_stereo/config/intrinsics.yml",
                    "/home/nicola/iri_ws/src/basler_stereo/config/extrinsics.yml");
  sv.initUndistortionRectifyMaps();
  sv.initStereoMatcher(sv::SGBM,"/home/nicola/iri_ws/src/basler_stereo/config/sgbm_parameters.yml");
  sv.isVerticalStereo = true;

  ROS_INFO("Stereo system initialized.");

  ros::Rate loop_rate(10);

  while(ros::ok())
  {
    // if none is subscribed jump to the next loop
    if(pub_pcl.getNumSubscribers() == 0) 
    {
      ROS_INFO("Waiting someone to subscribe to topic %s",pub_pcl.getTopic().c_str());
      while(ros::ok() && pub_pcl.getNumSubscribers() == 0){}
    }

    // check if the images are not old, here we consider 1 seconds but it should be
    // chosen accordingly to the time the algorithm takes to do all the stuff.
    // if the image is older than 1 second
    left = left && (ros::Time::now().toSec() - stamp_left.toSec()) > 1.0 ? false : left;
    // if the image is older than 1 second
    right = right && (ros::Time::now().toSec() - stamp_right.toSec()) > 1.0 ? false : right;

    // If both frames have been received
    // There is NO SINCRHONIZATION 
    if(left && right) 
    {
      sv.loadFrameLeft(img1->image);
      sv.loadFrameRight(img2->image);
      sv.adjustFrames();
      sv.rectifyFrames();
      sv.runStereoMatch(true, 4,2.00);
      static pcl::PointCloud<pcl::PointXYZRGB>::Ptr cloud(new pcl::PointCloud<pcl::PointXYZRGB>);
      static sensor_msgs::PointCloud2 pcl_msg;
      sv.getPointCloud(cloud);
      std::cout << "points in point cloud: " << cloud->points.size() << std::endl;      
      pcl::toROSMsg(*cloud,pcl_msg);
      pcl_msg.header.frame_id = "left_camera_optical_frame";
      pcl_msg.header.stamp = ros::Time::now();

      pub_pcl.publish(pcl_msg);
      
      ROS_INFO("Publishing point cloud: %d points",pcl_msg.data.size());
    }
    else
    {
      ROS_WARN("No images!");
    }

    ros::spinOnce();
    loop_rate.sleep();
  }

  return 0;
}