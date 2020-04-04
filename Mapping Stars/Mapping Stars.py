from scipy import ndimage
import numpy as np
from PIL import Image
from collections import Counter
import math as m
import os
import matplotlib.pyplot as plt

def print_centroids(centroids,image_label):
    """
    Print out the centroids found on image_label image
    """
    print(f"Centroids on {image_label} image:")
    j=1;
    for centroid in centroids:
        print(f"{int(centroid[1])} ",end='')
        print(int(centroid[0]),end='')
        if j!= len(centroids):
            print(' ',end='')
        j+=1
    print('\n',end='')


def match_shapes(image,objects_im,centroids_im):
    """
    The function matches objets in objects_im to the corresponding centroid in
    centroids_im and extracts the shape of an object, using characteristical 
    properties for each shape. Function returs shape and their indicies in the 
    centroids_im list.
    
    Parameters
    -----
    image : PIL image object

    objects_im : objects returned by ndimage.measurements.find_objects() function
    
    centroids_im: list that contatins Centroids
    Returns
    -----
    shapes: list of shapes
    ind_of_objects: List of indicies of the shapes in centroids_im list
    """
    shapes=list(range(0,len(objects_im)))
    ind_of_objects=list(range(0,len(objects_im)))
    for objects in objects_im:
       topleft=(objects[0].start,objects[1].start) 
       w=objects[1].stop-objects[1].start
       h=objects[0].stop-objects[0].start
       for centroids in centroids_im:
           if (centroids[0] > topleft[0]) and (centroids[0] < topleft[0]+h) and (centroids[1] > topleft[1]) and (centroids[1] < topleft[1]+w):
               match_centr=centroids_im.index(centroids)  
       [h_im,w_im]=np.shape(image[objects])
       mask=np.zeros((h_im+2,w_im))
       mask[1:h_im+1,:]=image[objects]
       [h1,w1]=np.shape(mask)
       pixel=0
       transitions=0
       start=int(w1/2)
       for i in range(0,h1):
          if pixel != mask[i][start]:
              transitions+=1
              pixel=mask[i][start]
       np.resize(image[objects],(h_im,w_im))
       if transitions==4:
           shapes[match_centr]='donut'
       elif transitions==8:
           shapes[match_centr]='flower'
       elif transitions==12:
           shapes[match_centr]='spiral'
       else:
           mean=ndimage.measurements.mean(image[objects]);
           if mean > 60:
               if mean > 127:
                   shapes[match_centr]='circle' 
               else:
                   shapes[match_centr]='star'
           else:
               shapes[match_centr]='cross'
       ind_of_objects[objects_im.index(objects)]=match_centr
    return (shapes,ind_of_objects)
def print_shapes(shapes,image_label):
    """
    Print out the shapes found on image_label image
    """
    print(f"Shapes in {image_label} image:")
    j=1
    for shape in shapes:
        print(shape,end='')
        if j!= len(shapes):
            print(' ',end='')
        j+=1
    print('\n',end='')
def find_min_dist_centroid(centroids,centroid_target):
    """
    The function finds the centroid (in the list of centroids) that is closest
    to the centroid_target centroid. Closest in terms of Euclidean distance.
    
    Parameters
    -----
    centroids : list of centroids

    centroid_target : centroid 
    
    Returns
    -----
    min_dst: centroid 
    """
    distance=[]
    for centroid in centroids:
        distance.append(((centroid[0] - centroid_target[0])**2 + (centroid[1] - centroid_target[1])**2)**(1/2))
    distance = np.asarray(distance).copy()
    min_dist = centroids[np.argmin(distance)]
    return min_dist
def check_angle_of_roation(d1,d2,angle):
    """
    if the positive angle1 from x-axis (in the counterclockwise direction) of
    dot d1 is smaller than the angle2 of dot d2, then the function returns
    2*pi-angle. Otherwise it returns angle
    
    Parameters
    -----
    d1 : dot1

    d2 : dot2
    
    angle: angle in radians
    Returns
    -----
    angle: angle in radians
    """
    x1,y1,_ = d1
    x2,y2,_ = d2
    angle1 = m.atan2(-y1,x1)
    angle2 = m.atan2(-y2,x2)
    if(angle1<0):
        angle1 = 2*m.pi+angle1
    if(angle2<0):
        angle2 = 2*m.pi+angle2
    if(angle1<angle2):
        angle = 2*m.pi-angle
    return angle


if __name__=="__main__":
    # reading input images
    print("Which example you want to test? (please provide single integer)")
    example = input()
    print()
    current_dir = os.getcwd()
    img1 = Image.open(os.path.join(current_dir,"publicDataset","public","set",example+"_src.png"))
    img2 = Image.open(os.path.join(current_dir,"publicDataset","public","set",example+"_dst.png"))
    plt.figure(1)
    plt.imshow(img1)
    plt.title("Source image")
    plt.figure(2)
    plt.imshow(img2)
    plt.title("Distorted image")
    # reading coordinates of the stars
    txt_file = open(os.path.join(current_dir,"publicDataset","public","input","in_"+example+".txt"),"r") 
    lines = txt_file.readlines()
    stars = []
    for line in lines[2:]:
        x,y = line.strip().split(sep=' ')
        stars.append((int(x),int(y)))
    # preprocess images
    image1 = np.asarray(img1).copy()
    image2 = np.asarray(img2).copy()
    image1 = np.where(image1>127, 255, 0)
    image2 = np.where(image2>127, 255, 0)
    # extract centroids
    labels_src, obj_num_src=ndimage.label(image1)
    labels_dst, obj_num_dst=ndimage.label(image2)
    centroids_src=ndimage.measurements.center_of_mass(image1,labels_src,list(range(1,obj_num_src+1)))
    centroids_dst=ndimage.measurements.center_of_mass(image2,labels_dst,list(range(1,obj_num_dst+1)))
    # print centroids
    print_centroids(centroids_src,"source")
    print_centroids(centroids_dst,"distorted")
    # find labeled objects
    objects_src=ndimage.measurements.find_objects(labels_src)
    objects_dst=ndimage.measurements.find_objects(labels_dst)
    # determine the shapes (class) of objects in image
    shapes_src=[]
    shapes_dst=[]
    shapes_src,ind_of_obj_src=match_shapes(image1,objects_src,centroids_src)
    shapes_dst,ind_of_obj_dst=match_shapes(image2,objects_dst,centroids_dst)
    
    # printing shapes
    print()
    print_shapes(shapes_src,"source")
    print_shapes(shapes_dst,"distorted")
    
    # find most common object on 2 images (shapes is sorted in the way that
    # each shape is in the same place as its centroid in the centroids list)
    # that is why we can use most_common shape even if it is not unique
    counter=Counter(shapes_src)
    most_common_src=counter.most_common(1)[0][0]
    counter=Counter(shapes_dst)
    most_common_dst=counter.most_common(1)[0][0]
    # find scaling 
    dim_src=np.shape(image1[objects_src[ind_of_obj_src[shapes_src.index(most_common_src)]]])[0]
    dim_dst=np.shape(image2[objects_dst[ind_of_obj_dst[shapes_dst.index(most_common_dst)]]])[0]
    scaling=dim_dst/dim_src
    # find translation
    centroid_src=ndimage.measurements.center_of_mass(image1) #centroid_src is center of mass on source image
    centroid_dst=ndimage.measurements.center_of_mass(image2) #centroid_dst is center of mass on distorted image
    translation_x = centroid_dst[1]-centroid_src[1]*scaling #width
    translation_y = centroid_dst[0]-centroid_src[0]*scaling #height
    # finding an angle (find the centroids closest to the centers of masses on images, and then find the angle between them)
    min_src = find_min_dist_centroid(centroids_src,centroid_src) 
    min_dst = find_min_dist_centroid(centroids_dst,centroid_dst)
    xs_min,ys_min = min_src[1]*scaling+translation_x,min_src[0]*scaling+translation_y
    xd_min,yd_min = min_dst[1],min_dst[0]
    #cosine theorem
    a=(((xd_min-centroid_dst[1])**2+(yd_min-centroid_dst[0])**2)**(1/2))
    b=(((xs_min-centroid_dst[1])**2+(ys_min-centroid_dst[0])**2)**(1/2))
    c=(((xd_min-xs_min)**2+(yd_min-ys_min)**2)**(1/2))
    cos=-(c**2-a**2-b**2)/(2*a*b)
    angle=m.acos(cos)
    # Matrix that translates coordinate sistem in the origin to the centroid_dst
    To = np.array([[1,0,centroid_dst[1]],[0,1,centroid_dst[0]],[0,0,1]])
    # Matrix that translates coordinate sistem around centroid_dst to the origin
    To_neg = np.array([[1,0,-centroid_dst[1]],[0,1,-centroid_dst[0]],[0,0,1]]) 
    # Translate coordiantes to the origin and check if you should take 2*pi-angle
    angle = check_angle_of_roation(np.dot(To_neg,np.array([xs_min,ys_min,1])),np.dot(To_neg,np.array([xd_min,yd_min,1])),angle)
    print(f"\nAngle in degrees: {m.degrees(angle)}")
    print(f"Scaling: {scaling}")
    print(f"Translation: {translation_x} {translation_y}")
    # Preform scaling, translation and rotation 
    print("\nStars: ")
    stars_dst=[]
    for i in range(0,3):
        stars_src = np.array(stars[i])
        T = np.array([translation_x,translation_y])
        R = np.array([[m.cos(angle),-m.sin(angle),0],[m.sin(angle),m.cos(angle),0],[0,0,1]])
        S = scaling
        # We found an angle of rotation around the center of the mass in the distorted image.
        # In order to perform rotation with matrix R (which is rotation around the origin),
        # we need to translate coordinates to the origin with matrix To_neg, perform rotation
        # with matrix R and translate back the coordinates to the center of mass with matrix To
        coord_dst = np.dot(To,np.dot(R,np.dot(To_neg,np.append(stars_src*S + T,1))))
        stars_dst.append(tuple(coord_dst))
        # plot stars on the images
        plt.figure(1)
        plt.plot(stars_src[0],stars_src[1],'ro',linewidth=5)
        plt.figure(2)
        plt.plot(stars_dst[i][0],stars_dst[i][1],'bo',linewidth=5)
        # print stars on std output
        print(f"{i+1}: Source-->{int(stars_src[0])} ",end='')
        print(f"{int(stars_src[1])}",end=', ')
        print(f"Distorted-->{int(stars_dst[i][0])} ",end='')
        print(f"{int(stars_dst[i][1])}")
    print("\nStars are printed red on the source image, and blue on the distorted image.")


