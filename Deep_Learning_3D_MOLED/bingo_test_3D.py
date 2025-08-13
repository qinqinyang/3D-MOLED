# -*- coding: UTF-8 -*-
'''
Created on Wed Oct 9 20:15:00 2019

@author: Qinqin Yang
'''
import os
import argparse
import scipy.io as matio

from network.R2AttUNet_3d import Inference

from tools.evaluation import *
import numpy as np

def rotate_tensor(data,angle=None):
    c = data.shape[0]
    for ci in range(0, c):
        data[ci,:,:] = np.rot90(data[ci,:,:],angle)
    return data

def flip_tensor(data,mode=None):
    c = data.shape[0]
    for ci in range(0, c):
        data[ci,:,:] = np.flip(data[ci,:,:],mode)
    return data

def load_data_Mat_test(config):
    data_in = matio.loadmat(config.image_path)
    input_sets = data_in['oled']
    input_sets = input_sets / input_sets.max()
    input_sets = input_sets * config.scale_factor

    input_sets = np.expand_dims(input_sets,axis=0)
    input_sets = torch.from_numpy(input_sets)

    return input_sets

def test_v(config):
    #-----选择GPU-----#
    os.environ['CUDA_VISIBLE_DEVICES'] = config.GPU_NUM

    #-----使每次生成的随机数相同-----#
    np.random.seed(1)
    torch.manual_seed(1)

    # -----地址-----#
    model_dir = os.path.join(config.model_path, config.model_name)
    if not os.path.exists(model_dir):
        print('Model not found, please check you path to model')
        print(model_dir)
        os._exit(0)
    if not os.path.exists(config.result_path):
        os.makedirs(config.result_path)

    #-----读取数据-----#
    images = load_data_Mat_test(config)

    #-----模型-----#
    net = Inference(config.INPUT_C,config.OUTPUT_C,config.FILTERS)

    if torch.cuda.is_available():
        net.cuda()
        net.load_state_dict(torch.load(model_dir))
    else:
        net.load_state_dict(torch.load(model_dir, map_location=torch.device('cpu')))

    #-----载入模型参数-----#

    print('Model parameters loaded!')

    # Setup device
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # ********************************************test*****************************************************#
    net.eval()
    images = images.type(torch.FloatTensor)
    images = images.to(device)

    SR = net(images)  # forward

    OUT_test = np.squeeze(SR.permute(0, 2, 3, 4, 1).cpu().detach().numpy())

    #-----保存为mat文件-----#
    print('.' * 30)
    print('OUT_test:', OUT_test.shape)
    print('.' * 30)
    tarname = os.path.join(config.result_path, config.save_name)
    matio.savemat(
        tarname,
        {
            'output': OUT_test
        })
    print('Save result in ',tarname)
    print('.' * 30)
    print('Finished!')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # experiment name
    parser.add_argument('--name', type=str, default='experiment')
    parser.add_argument('--data_dir', type=str, default='./dataset/')
    parser.add_argument('--GPU_NUM', type=str, default='0')

    # model hyper-parameters
    parser.add_argument('--INPUT_H', type=int, default=224)
    parser.add_argument('--INPUT_W', type=int, default=224)
    parser.add_argument('--INPUT_C', type=int, default=4)
    parser.add_argument('--OUTPUT_C', type=int, default=1)
    parser.add_argument('--LABEL_C', type=int, default=2)
    parser.add_argument('--DATA_C', type=int, default=2)
    parser.add_argument('--FILTERS', type=int, default=64)
    parser.add_argument('--CROP_SIZE', type=int, default=64)
    # test hyper-parameters
    parser.add_argument('--BATCH_SIZE', type=int, default=1)

    parser.add_argument('--model_path', type=str, default='./models/')
    parser.add_argument('--model_name', type=str, default='')
    parser.add_argument('--result_path', type=str, default='./test_result/')
    parser.add_argument('--save_name', type=str, default='')
    parser.add_argument('--test_dir', type=str, default='')
    parser.add_argument('--scale_factor', type=float, default=1)


    config = parser.parse_args()
    config.scale_factor = 1

    config.model_name = 'OLED3D_t2star_size64_R2AttUNet_epoch_4000.pth'

    # BUDA no motion
    config.image_path = 'OLED_3D_BUDA_SENSE2_01_mat_3D/OLED_3D_BUDA_SENSE2_mat_3D.mat'
    config.result_path = 'OLED_3D_BUDA_SENSE2_01_mat_3D/'
    config.save_name = 'OLED3D_t2star_BUDA_results.mat'

    with torch.no_grad():
        test_v(config)