import os
import random
import numpy as np
import scipy.io
from torch.utils import data
from torchvision import transforms as T

def load_data_Mat(image_path, config):
    data_in = scipy.io.loadmat(image_path)
    input_sets = data_in['oled']
    label_sets = data_in['t2star']

    return input_sets,label_sets

def load_data_Mat_test(image_path, config):
    data_in = scipy.io.loadmat(image_path)
    input_sets = data_in['oled']
    temp = np.zeros((224,224))
    temp = np.expand_dims(temp,axis=2)
    temp = np.expand_dims(temp, axis=0)
    temp = np.concatenate((temp,temp,temp,temp),axis=0)
    input_sets = np.concatenate((temp,input_sets,temp),axis=3)
    label_sets = input_sets[0:1,:,:,:]

    return input_sets,label_sets

class ImageFolder(data.Dataset):
    """Load Variaty Chinese Fonts for Iterator. """

    def __init__(self, root, config, crop_key, mode='train'):
        """Initializes image paths and preprocessing module."""
        self.config = config
        self.root = root
        self.mode = mode
        self.crop_key = crop_key
        self.crop_size = config.CROP_SIZE
        self.image_dir = os.path.join(root, mode)

        self.image_paths = list(map(lambda x: os.path.join(self.image_dir, x), os.listdir(self.image_dir)))
        print("image count in {} path :{}".format(self.mode, len(self.image_paths)))
        self.image_paths.sort(reverse=True)

    def __getitem__(self, index):
        """Reads an image from a file and preprocesses it and returns."""
        image_path = self.image_paths[index]
        if self.mode == 'brain':
            image,GT = load_data_Mat_test(image_path, self.config)
        else:
            image,GT = load_data_Mat(image_path, self.config)

        if self.crop_key:
            # -----RandomCrop----- #
            (c,h, w, d) = image.shape
            th, tw = self.crop_size, self.crop_size
            i = random.randint(0, h - th)
            j = random.randint(0, w - th)
            k = random.randint(0, d - th)
            if w <= th and h <= th and d <= th:
                print('Error! Your input size is too small: %d is smaller than crop size %d ' % (w, self.crop_size))
                return
            image = image[:,i:i + th, j:j + th, k:k+th]
            GT = GT[:,i:i + th, j:j + th, k:k+th]


        return image, GT

    def __len__(self):
        """Returns the total number of font files."""
        return len(self.image_paths)


def get_loader(image_path, config, crop_key, num_workers, shuffle=True,mode='train'):
    """Builds and returns Dataloader."""

    dataset = ImageFolder(root=image_path, config=config, crop_key=crop_key, mode=mode)
    data_loader = data.DataLoader(dataset=dataset,
                                  batch_size=config.BATCH_SIZE,
                                  shuffle=shuffle,
                                  num_workers=num_workers,
                                  pin_memory=True)
    return data_loader

def load_data_Mat_all(image_path):
    filen = len(image_path)
    input_list = []
    output_list = []

    for filei in range(0, filen):
        filename = image_path[filei]
        data_in = scipy.io.loadmat(filename)

        input_sets = data_in['oled']
        input_sets = input_sets/input_sets.max()
        label_sets = data_in['t2star']
        input_list.append(input_sets)
        output_list.append(label_sets)
        print(filename)

    return input_list,output_list

def load_data_Mat_all_test(image_path):
    filen = len(image_path)
    input_list = []
    output_list = []

    for filei in range(0, filen):
        filename = image_path[filei]
        data_in = scipy.io.loadmat(filename)

        input_sets = data_in['oled']
        input_sets = input_sets / input_sets.max()
        input_list.append(input_sets)
        output_list.append(input_sets)
        print(filename)

    return input_list,output_list

class ImageFolderfast(data.Dataset):
    """Load Variaty Chinese Fonts for Iterator. """

    def __init__(self, root, config, crop_key, mode='train'):
        """Initializes image paths and preprocessing module."""
        self.config = config
        self.root = root
        self.mode = mode
        self.crop_key = crop_key
        self.crop_size = config.CROP_SIZE
        self.image_dir = os.path.join(root, mode)

        self.image_paths = list(map(lambda x: os.path.join(self.image_dir, x), os.listdir(self.image_dir)))
        print("image count in {} path :{}".format(self.mode, len(self.image_paths)))
        self.image_paths.sort(reverse=True)
        print(self.image_paths)
        if self.mode == 'train':
            self.input_list, self.label_list = load_data_Mat_all(self.image_paths)
        elif self.mode == 'brain':
            self.input_list, self.label_list = load_data_Mat_all_test(self.image_paths)

    def __getitem__(self, index):
        """Reads an image from a file and preprocesses it and returns."""
        image = self.input_list[index]
        GT = self.label_list[index]

        if self.crop_key:
            # -----RandomCrop----- #
            (c,h, w, d) = image.shape
            th, tw = self.crop_size, self.crop_size
            i = random.randint(0, h - th)
            j = random.randint(0, w - th)
            k = random.randint(0, d - th)
            if w <= th and h <= th and d <= th:
                print('Error! Your input size is too small: %d is smaller than crop size %d ' % (w, self.crop_size))
                return
            image = image[:,i:i + th, j:j + th, k:k+th]
            #image = image / image.max()
            GT = GT[:,i:i + th, j:j + th, k:k+th]


        return image, GT

    def __len__(self):
        """Returns the total number of font files."""
        return len(self.image_paths)

def get_loader_fast(image_path, config, crop_key, num_workers, shuffle=True,mode='train'):
    """Builds and returns Dataloader."""

    dataset = ImageFolderfast(root=image_path, config=config, crop_key=crop_key, mode=mode)
    data_loader = data.DataLoader(dataset=dataset,
                                  batch_size=config.BATCH_SIZE,
                                  shuffle=shuffle,
                                  num_workers=num_workers,
                                  pin_memory=True)
    return data_loader