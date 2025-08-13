# -*- coding: UTF-8 -*-
'''
Created on Wed Oct 9 20:15:00 2019

@author: Qinqin Yang
'''
import os
import argparse
import scipy.io as scio

from network.UNet import Inference

from tools.evaluation import *
import numpy as np

def load_data_mat_test(image_path):
    data_in = scio.loadmat(image_path)
    input_sets = data_in['t2']

    return input_sets

def test(config):
    os.environ['CUDA_VISIBLE_DEVICES'] = config.GPU_NUM

    np.random.seed(1)
    torch.manual_seed(1)

    model_dir = os.path.join(config.model_path, config.name + '.pth')
    if not os.path.exists(model_dir):
        print('Model not found, please check you path to model')
        print(model_dir)
        os._exit(0)
    if not os.path.exists(config.result_path):
        os.makedirs(config.result_path)

    net = Inference(config.INPUT_C,config.OUTPUT_C,config.FILTERS)

    if torch.cuda.is_available():
        net.cuda()

    net.load_state_dict(torch.load(model_dir))
    print('Model parameters loaded!')

    # Setup device
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # ********************************************test*****************************************************#
    net.eval()

    filenum = len(os.listdir(config.test_dir))
    for i in range(1,filenum):

        image_path = config.test_dir + str(i) + '.mat'
        images = load_data_mat_test(image_path)

        images = np.expand_dims(images, 0)
        images = np.expand_dims(images, 1)

        images = torch.from_numpy(images)

        images = images.type(torch.FloatTensor)
        images = images.to(device)

        SR = net(images)  # forward

        OUT_test = SR.permute(2, 3, 0, 1).cpu().detach().numpy()

        #-----保存为mat文件-----#
        print('OUT_test:', OUT_test.shape)
        scio.savemat(
            os.path.join(config.result_path, str(i) + '.mat'),
            {
                't2out': OUT_test
            })
        print('Save result in ',config.name + '_result_' + config.test_dir + str(i) + '.mat')
        print('Finished!')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # experiment name
    parser.add_argument('--name', type=str, default='experiment')
    parser.add_argument('--data_dir', type=str, default='/data/')
    parser.add_argument('--GPU_NUM', type=str, default='0')

    # model hyper-parameters
    parser.add_argument('--INPUT_H', type=int, default=256)
    parser.add_argument('--INPUT_W', type=int, default=256)
    parser.add_argument('--INPUT_C', type=int, default=1)
    parser.add_argument('--OUTPUT_C', type=int, default=1)
    parser.add_argument('--FILTERS', type=int, default=64)

    # test hyper-parameters
    parser.add_argument('--model_path', type=str, default='./models/')
    parser.add_argument('--result_path', type=str, default='/data/')
    parser.add_argument('--test_dir', type=str, default='')

    config = parser.parse_args()

    config.test_dir = 'test_T2star2T1/T2star_input/'
    config.result_path = 'test_T2star2T1/T1_output/'

    config.name = 'T2star2T1_UNet'
    test(config)