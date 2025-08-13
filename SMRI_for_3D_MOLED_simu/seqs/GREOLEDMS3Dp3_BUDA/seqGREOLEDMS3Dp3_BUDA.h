#ifndef _SEQGREOLEDMS3Dp3_BUDA_H
#define _SEQGREOLEDMS3Dp3_BUDA_H

#include "BaseSeq.h"


class SeqGREOLEDMS3Dp3_BUDA: public BaseSeq
{
    public:
        SeqGREOLEDMS3Dp3_BUDA(FOVStruct fover, KSpaceStruct kspacer,SeqComStruct seqComer, std::string configPath);
        ~SeqGREOLEDMS3Dp3_BUDA();
        bool parseConfig(std::string configPath);
        bool makeSeq(int fileId);

        double calculateGraAmp(double dt, double gAmpCoeff, int dType);
        void initGREOLEDMS3Dp3_BUDAParameters(int fileID);

        void randomShiftGra(int loopi);
        float getShiftGra(int time, int direc);
        
    private:

        double m_epiMiddleStamp;
        bool m_shiftUseBlipT;

        /* Shot */
        int m_shotNum;
        int m_ETL;
        double m_tr;
        double Shiftrewind;
        
        int m_dummy;
        double m_lastRelaxTime;
        double m_lastRelaxTime2;
        bool m_motionFlag;

        double m_shiftG1XAmp;
        double m_shiftG1YAmp;
        double m_shiftG2XAmp;
        double m_shiftG2YAmp;
        double m_shiftG3XAmp;
        double m_shiftG3YAmp;

        RFCfgS m_rf1;
        GradientCfgS m_shiftG1;
        RFCfgS m_rf2;
        GradientCfgS m_shiftG2;

        RFCfgS m_rf3;
        GradientCfgS m_shiftG3;

        bool m_shiftGraFlag;
        ShiftGra m_xShiftGra;
        ShiftGra m_yShiftGra;
        ShiftGra m_zShiftGra;

        int slice_num;
        double m_samprate;

        std::vector<double> m_randv;

};
#endif