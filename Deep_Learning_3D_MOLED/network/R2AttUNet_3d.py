import torch
import torch.nn as nn
from network.ops import TotalVariation

class up_conv(nn.Module):
    def __init__(self, ch_in, ch_out):
        super(up_conv, self).__init__()
        self.up = nn.Sequential(
            nn.Upsample(scale_factor=2),
            nn.Conv3d(ch_in, ch_out, kernel_size=3, stride=1, padding=1, bias=True),
            #nn.BatchNorm2d(ch_out),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        x = self.up(x)
        return x


class Recurrent_block(nn.Module):
    def __init__(self, ch_out, t=2):
        super(Recurrent_block, self).__init__()
        self.t = t
        self.ch_out = ch_out
        self.conv = nn.Sequential(
            nn.Conv3d(ch_out, ch_out, kernel_size=3, stride=1, padding=1, bias=True),
            #nn.BatchNorm2d(ch_out),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        for i in range(self.t):

            if i == 0:
                x1 = self.conv(x)

            x1 = self.conv(x + x1)
        return x1


class RRCNN_block(nn.Module):
    def __init__(self, ch_in, ch_out, t=2):
        super(RRCNN_block, self).__init__()
        self.RCNN = nn.Sequential(
            Recurrent_block(ch_out, t=t),
            Recurrent_block(ch_out, t=t)
        )
        self.Conv_1x1 = nn.Conv3d(ch_in, ch_out, kernel_size=1, stride=1, padding=0)

    def forward(self, x):
        x = self.Conv_1x1(x)
        x1 = self.RCNN(x)
        return x + x1


class outconv(nn.Module):
    def __init__(self, in_ch, out_ch):
        super(outconv, self).__init__()
        self.conv = nn.Sequential(
            nn.Conv3d(in_ch, 1, kernel_size=3, stride=1, padding=1),
        )
    def forward(self, x):
        x = self.conv(x)
        return x


class Attention_block(nn.Module):
    def __init__(self, F_g, F_l, F_int):
        super(Attention_block, self).__init__()
        self.W_g = nn.Sequential(
            nn.Conv3d(F_g, F_int, kernel_size=1, stride=1, padding=0, bias=True),
            #nn.BatchNorm2d(F_int)
        )

        self.W_x = nn.Sequential(
            nn.Conv3d(F_l, F_int, kernel_size=1, stride=1, padding=0, bias=True),
            #nn.BatchNorm2d(F_int)
        )

        self.psi = nn.Sequential(
            nn.Conv3d(F_int, 1, kernel_size=1, stride=1, padding=0, bias=True),
            #nn.BatchNorm2d(1),
            nn.Sigmoid()
        )

        self.relu = nn.ReLU(inplace=True)

    def forward(self, g, x):
        g1 = self.W_g(g)
        x1 = self.W_x(x)
        psi = self.relu(g1 + x1)
        psi = self.psi(psi)

        return x * psi

class Inference(nn.Module):
    def __init__(self,img_ch=3, output_ch=1,filter_dim=64, t=2):
        super(Inference, self).__init__()

        self.Maxpool = nn.MaxPool3d(kernel_size=2, stride=2)
        self.Upsample = nn.Upsample(scale_factor=2)

        self.RRCNN1 = RRCNN_block(ch_in=img_ch, ch_out=filter_dim, t=t)

        self.RRCNN2 = RRCNN_block(ch_in=filter_dim, ch_out=filter_dim*2, t=t)

        self.RRCNN3 = RRCNN_block(ch_in=filter_dim*2, ch_out=filter_dim*4, t=t)

        self.RRCNN4 = RRCNN_block(ch_in=filter_dim*4, ch_out=filter_dim*8, t=t)

        self.RRCNN5 = RRCNN_block(ch_in=filter_dim*8, ch_out=filter_dim*16, t=t)

        self.Up5 = up_conv(ch_in=filter_dim*16, ch_out=filter_dim*8)
        self.Att5 = Attention_block(F_g=filter_dim*8, F_l=filter_dim*8, F_int=filter_dim*4)
        self.Up_RRCNN5 = RRCNN_block(ch_in=filter_dim*16, ch_out=filter_dim*8, t=t)

        self.Up4 = up_conv(ch_in=filter_dim*8, ch_out=filter_dim*4)
        self.Att4 = Attention_block(F_g=filter_dim*4, F_l=filter_dim*4, F_int=filter_dim*2)
        self.Up_RRCNN4 = RRCNN_block(ch_in=filter_dim*8, ch_out=filter_dim*4, t=t)

        self.Up3 = up_conv(ch_in=filter_dim*4, ch_out=filter_dim*2)
        self.Att3 = Attention_block(F_g=filter_dim*2, F_l=filter_dim*2, F_int=filter_dim)
        self.Up_RRCNN3 = RRCNN_block(ch_in=filter_dim*4, ch_out=filter_dim*2, t=t)

        self.Up2 = up_conv(ch_in=filter_dim*2, ch_out=filter_dim)
        self.Att2 = Attention_block(F_g=filter_dim, F_l=filter_dim, F_int=32)
        self.Up_RRCNN2 = RRCNN_block(ch_in=filter_dim*2, ch_out=filter_dim, t=t)

        self.Conv1 = outconv(filter_dim, output_ch)

    def forward(self, x):
        # encoding path
        x1 = self.RRCNN1(x)

        x2 = self.Maxpool(x1)
        x2 = self.RRCNN2(x2)

        x3 = self.Maxpool(x2)
        x3 = self.RRCNN3(x3)

        x4 = self.Maxpool(x3)
        x4 = self.RRCNN4(x4)

        x5 = self.Maxpool(x4)
        x5 = self.RRCNN5(x5)

        # decoding + concat path
        d5 = self.Up5(x5)
        x4 = self.Att5(g=d5, x=x4)
        d5 = torch.cat((x4, d5), dim=1)
        d5 = self.Up_RRCNN5(d5)

        d4 = self.Up4(d5)
        x3 = self.Att4(g=d4, x=x3)
        d4 = torch.cat((x3, d4), dim=1)
        d4 = self.Up_RRCNN4(d4)

        d3 = self.Up3(d4)
        x2 = self.Att3(g=d3, x=x2)
        d3 = torch.cat((x2, d3), dim=1)
        d3 = self.Up_RRCNN3(d3)

        d2 = self.Up2(d3)
        x1 = self.Att2(g=d2, x=x1)
        d2 = torch.cat((x1, d2), dim=1)
        d2 = self.Up_RRCNN2(d2)

        T2 = self.Conv1(d2)

        return T2
