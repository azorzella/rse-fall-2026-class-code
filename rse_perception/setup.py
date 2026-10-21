from glob import glob
import os

from setuptools import find_packages, setup

package_name = 'rse_perception'

setup(
    name=package_name,
    version='0.1.0',
    packages=find_packages(exclude=['test']),
    data_files=[
        ('share/ament_index/resource_index/packages', ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml', 'README.md', 'LICENSE']),
        (os.path.join('share', package_name, 'launch'), glob('launch/*.launch.py')),
        (os.path.join('share', package_name, 'config'), glob('config/*.yaml')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='dfseifer',
    maintainer_email='dfseifer@unr.edu',
    description='Student starter for transformed fiducial detections and RViz markers.',
    license='BSD-3-Clause',
    entry_points={
        'console_scripts': [
            'apriltag_pose_adapter = rse_perception.apriltag_pose_adapter:main',
            'detection_to_marker = rse_perception.detection_to_marker:main',
        ],
    },
)
