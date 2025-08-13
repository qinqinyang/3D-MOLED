# -*- coding: UTF-8 -*-
'''
Created on Wed Oct 9 20:15:00 2019
Modified on Thur Aug 19 14:30:00 2021

@author: Qinqin Yang
'''
import os
import csv
import argparse
import numpy as np
import time

import torch
from network.UNet import Inference

from tools.data_loader import get_loader
from tools.misc import mkexperiment,save_torch_result


def main(config):
    os.environ['CUDA_VISIBLE_DEVICES'] = config.GPU_NUM
    torch.backends.cudnn.benchmark = True

    np.random.seed(1)
    torch.manual_seed(1)
    time2 = 0

    experiment_path = mkexperiment(config, cover=True)
    save_inter_result = os.path.join(experiment_path, 'inter_result')
    model_path = os.path.join(config.model_path,config.name)

    data_dir = config.data_dir
    train_batch = get_loader(data_dir, config, crop_key=config.CROP_KEY,num_workers=3, shuffle=True, mode='train')
    brain_batch = get_loader(data_dir, config, crop_key=False,num_workers=1, shuffle=False, mode='brain')

    net = Inference(config.INPUT_C, config.OUTPUT_C, config.FILTERS)

    scaler = torch.cuda.amp.GradScaler()

    criterion = torch.nn.L1Loss()
    criterion_vgg = torch.nn.L1Loss()

    if torch.cuda.is_available():
        net.cuda()
        criterion.cuda()

    optimizer = torch.optim.Adam(net.parameters(), lr=config.lr,betas=(config.beta1, config.beta2))

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    f = open(os.path.join(experiment_path, 'result.csv'), 'a', encoding='utf-8', newline='')
    wr = csv.writer(f)
    wr.writerow(['train loss', 'val loss','val nmse', 'lr', 'total_iters', 'epochs'])

    if config.mode =='train':
        total_iters = 0
        for epoch in range(1,config.num_epochs+1):
            net = net.train()
            train_loss = 0
            train_length = 0

            # ********************************************train*****************************************************#
            for i,(images, GT) in enumerate(train_batch):
                images = images.type(torch.FloatTensor)
                GT = GT.type(torch.FloatTensor)

                images = images.to(device)
                GT = GT.to(device)

                optimizer.zero_grad()  # clear grad

                with torch.cuda.amp.autocast():
                    SR = net(images)  # forward
                    loss = criterion(SR, GT)


                train_loss += loss.item()
                scaler.scale(loss).backward()
                scaler.step(optimizer=optimizer)
                scaler.update()

                train_length += images.size(0)

                total_iters += 1

                # learing rate decay
                if (total_iters % config.lr_updata) == 0:
                    for param_group in optimizer.param_groups:
                        param_group['lr'] = param_group['lr'] * 0.8

                if total_iters%config.step == 0:
                    lr = optimizer.param_groups[0]['lr']
                    # # ********************************************VAL*****************************************************#
                    with torch.no_grad():
                        # Print the log info
                        time1 = time.clock()
                        temp_time = time1-time2
                        print(
                            'Epoch [%d/%d], Total_iters [%d], Train Loss: %.5f, lr: %.8f,time: %.3f' % (
                                epoch, config.num_epochs, total_iters,
                                train_loss / train_length, lr, temp_time))
                        time2 = time.clock()
                        wr.writerow([train_loss / train_length, lr, total_iters, epoch])

                        train_loss = 0
                        train_length = 0
                        ## ********************************************test_brain***********************************************#
                        for i, (brain_images, _) in enumerate(brain_batch):
                            brain_images = brain_images.type(torch.FloatTensor)
                            brain_images = brain_images.to(device)
                            SR_brain = net(brain_images)

                            # save result in fold
                            save_dir = os.path.join(save_inter_result, 'inter_t1_' + str(total_iters) + '_brain')
                            save_torch_result(SR_brain[:, 0:1, :, :], save_dir,
                                              format='png', cmap='gray', norm=False, crange=[0, 3.5])

                        #net.train()

            # -----save_model-----#
            if (epoch) % config.model_save_step == 0 and epoch > config.model_save_start:
                if not os.path.exists(model_path):
                    os.mkdir(model_path)
                torch.save(net.state_dict(), model_path + '/' + config.name + '_epoch_' +str(epoch) + '.pth')

        f.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # experiment name
    parser.add_argument('--name', type=str, default='experiment')
    parser.add_argument('--experiment_path', type=str, default='')
    parser.add_argument('--data_dir', type=str, default='./dataset/')
    parser.add_argument('--GPU_NUM', type=str, default='1')

    # model hyper-parameters
    parser.add_argument('--INPUT_H', type=int, default=256)
    parser.add_argument('--INPUT_W', type=int, default=256)
    parser.add_argument('--INPUT_C', type=int, default=1)
    parser.add_argument('--OUTPUT_C', type=int, default=1)
    parser.add_argument('--LABEL_C', type=int, default=6)
    parser.add_argument('--DATA_C', type=int, default=6)
    parser.add_argument('--FILTERS', type=int, default=64)

    parser.add_argument('--CROP_KEY', type=bool, default=True)
    parser.add_argument('--CROP_SIZE', type=int, default=96)

    # training hyper-parameters
    parser.add_argument('--num_epochs', type=int, default=1600)
    parser.add_argument('--BATCH_SIZE', type=int, default=8)
    parser.add_argument('--NUM_WORKERS', type=int, default=3)
    parser.add_argument('--lr', type=float, default=1e-4)
    parser.add_argument('--lr_updata', type=int, default=60000)  # epoch num for lr updata
    parser.add_argument('--beta1', type=float, default=0.9)  # momentum1 in Adam
    parser.add_argument('--beta2', type=float, default=0.999)  # momentum2 in Adam
    parser.add_argument('--regular', type=float, default=0.001)

    parser.add_argument('--step', type=int, default=500)
    parser.add_argument('--model_save_start', type=int, default=1)
    parser.add_argument('--model_save_step', type=int, default=200)
    # misc
    parser.add_argument('--mode', type=str, default='train')
    parser.add_argument('--model_path', type=str, default='./models/')
    parser.add_argument('--result_path', type=str, default='./result/')

    config = parser.parse_args()

    config.name = 'T2star2T1_UNet'
    main(config)
