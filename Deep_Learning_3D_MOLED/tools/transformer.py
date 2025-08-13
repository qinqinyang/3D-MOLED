import numpy as np
import torch
import random
import scipy.io as matio

def np_to_tensor(x):
    return torch.from_numpy(x.transpose((2, 0, 1)))

def np_rotation(x):
    angle = random.sample([0, 1, 2, 3], 1)
    return np.rot90(x, angle[0])


def np_RandomCrop(x, crop_size=64):
    w, h = x.shape[0], x.shape[1]

    if w == crop_size and h == crop_size:
        return x

    i = random.randint(0, h - crop_size)
    j = random.randint(0, w - crop_size)

    return x[i:i + crop_size, j:j + crop_size, :]

def mat_to_tensor(datapath,labelpath):
    data_mat = matio.loadmat(datapath)['data']
    label_mat = matio.loadmat(labelpath)['data']
    label_mat = np.expand_dims(label_mat, axis=2)
    return data_mat,label_mat

def tensor_to_patch(image, window_size):
    '''
    :param image: [1, w, h, c]
    :return:[total_patch, window_size, window_size, c]
    '''
    x_test = []
    avg_num = image.shape[-2]//window_size
    channel = image.shape[-1]
    for c in range(avg_num):
        for r in range(avg_num):
            x0 = c * window_size
            y0 = r * window_size
            x1 = x0 + window_size
            y1 = y0 + window_size
            x_test.append(image[0, x0:x1, y0:y1, :])
    return  np.reshape(x_test, [avg_num*avg_num, window_size, window_size, channel])

def patch_to_tensor(outimage, image , window_size):
    '''
    :param outimage: [total_patch, window_size, window_size, c]
    :param image: [w, h]
    :return: [w, h]
    '''
    i = 0
    avg_num = image.shape[-2] // window_size
    merge_img = np.zeros_like(image)
    outimage = np.array(outimage)
    outimage = np.squeeze(outimage, axis=0)
    for c in range(avg_num):
        for r in range(avg_num):
            x0 = c * window_size
            y0 = r * window_size
            x1 = x0 + window_size
            y1 = y0 + window_size
            merge_img[x0:x1, y0:y1]=outimage[i, :, :, 0]
            i += 1
    return merge_img