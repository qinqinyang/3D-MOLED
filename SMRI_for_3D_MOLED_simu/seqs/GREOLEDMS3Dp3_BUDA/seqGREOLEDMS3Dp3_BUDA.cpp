#include "seqGREOLEDMS3Dp3_BUDA.h"
#include "parse.h"
#include <iostream>

SeqGREOLEDMS3Dp3_BUDA::SeqGREOLEDMS3Dp3_BUDA(FOVStruct fover, KSpaceStruct kspacer, SeqComStruct seqComer, std::string configPath) : BaseSeq(
                                                                                                                               fover, kspacer, seqComer)
{
    /*  */
    this->m_isEPI = true;
    this->parseConfig(configPath);
    this->initParameters();
    this->m_randv = std::vector<double>(9, 0);
}
SeqGREOLEDMS3Dp3_BUDA::~SeqGREOLEDMS3Dp3_BUDA()
{
}

bool SeqGREOLEDMS3Dp3_BUDA::parseConfig(std::string configPath)
{

    std::string fileStr = this->readCfs(configPath);

    nlohmann::json configJson = nlohmann::json::parse(fileStr);

    this->m_shiftUseBlipT = configJson["ShiftUseBlipT"].get<bool>();
    this->m_rfInterval = configJson["RFInterval"].get<double>();
    this->m_shotNum = configJson["ShotNum"].get<int>();
    this->m_ETL = configJson["ETL"].get<int>();
    this->m_tr = configJson["TR"].get<double>();
    this->m_dummy = configJson["DummyScan"].get<int>();
    this->m_lastRelaxTime = configJson["LastRelaxTime"].get<double>();
    this->m_lastRelaxTime2 = configJson["LastRelaxTime2"].get<double>();

    this->m_motionFlag = configJson["MotionFlag"].get<bool>();

    this->m_rf1 = configJson["RF1"].get<RFCfgS>();
    this->m_rf2 = configJson["RF2"].get<RFCfgS>();
    this->m_rf3 = configJson["RF3"].get<RFCfgS>();

    this->m_shiftG1 = configJson["ShiftG1"].get<GradientCfgS>();
    this->m_shiftG2 = configJson["ShiftG2"].get<GradientCfgS>();
    this->m_shiftG3 = configJson["ShiftG3"].get<GradientCfgS>();
    this->Shiftrewind = configJson["Shiftrewind"].get<double>();

    this->m_shiftGraFlag = configJson["ShiftGraFlag"].get<bool>();

    this->m_xShiftGra.minG = configJson["XMinShiftGra"].get<float>();
    this->m_xShiftGra.maxG = configJson["XMaxShiftGra"].get<float>();
    this->m_yShiftGra.minG = configJson["YMinShiftGra"].get<float>();
    this->m_yShiftGra.maxG = configJson["YMaxShiftGra"].get<float>();
    this->m_zShiftGra.minG = configJson["ZMinShiftGra"].get<float>();
    this->m_zShiftGra.minG = configJson["ZMaxShiftGra"].get<float>();

    this->slice_num = configJson["Slices"].get<int>();
    this->m_samprate = configJson["SamplingRate"].get<double>();

    return true;
}

bool SeqGREOLEDMS3Dp3_BUDA::makeSeq(int fileId)
{
    this->setFileId(fileId);

    /* process before make sequence */
    this->processBeforeRun();

    this->initGREOLEDMS3Dp3_BUDAParameters(fileId);

    double shiftDt = 0;
    double currentTime = 0;
    double tmpDGxAmp = 0;
    double shotidx = 0;
    double budaidx = 0;
    double budatime = 0;

    for (int dummyId = 0; dummyId < this->m_dummy; dummyId++)
    {
            //shotidx = 0 - this->m_shotNum / 2.0f + 1;
            /* [1]: RF1 Pulse */
            this->pluginRF(
                this->rectRF(this->m_rf1.rfFlipAngle, this->m_rf1.rfDt, this->m_rf1.rfPhase, this->m_rf1.rfFreq));
            currentTime = this->m_rf1.middleStamp + this->m_rf1.rfDt / 2.0f;

            /* [2]: Relaxtion */
            this->pluginRelaxation(this->m_shiftG1.middleStamp - this->m_shiftG1.duration / 2.0f - currentTime);

            /* [3]: Shift Gradient1 */
            this->pluginGradient(this->m_shiftG1XAmp, this->m_shiftG1YAmp, 0, false, this->m_shiftG1.duration);
            currentTime = this->m_shiftG1.middleStamp + this->m_shiftG1.duration / 2.0f;

            /* [4]: Relaxtion */
            this->pluginRelaxation(this->m_rf2.middleStamp - this->m_rf2.rfDt / 2.0f - currentTime);

            /* [1]: RF2 Pulse */
            this->pluginRF(
                this->rectRF(this->m_rf2.rfFlipAngle, this->m_rf2.rfDt, this->m_rf2.rfPhase, this->m_rf2.rfFreq));
            currentTime = this->m_rf2.middleStamp + this->m_rf2.rfDt / 2.0f;

            /* [2]: Relaxtion */
            this->pluginRelaxation(this->m_shiftG2.middleStamp - this->m_shiftG2.duration / 2.0f - currentTime);

            /* [3]: Shift Gradient1 */
            this->pluginGradient(this->m_shiftG2XAmp, this->m_shiftG2YAmp, 0, false, this->m_shiftG2.duration);
            currentTime = this->m_shiftG2.middleStamp + this->m_shiftG2.duration / 2.0f;

            /* [4]: Relaxtion */
            this->pluginRelaxation(this->m_rf3.middleStamp - this->m_rf3.rfDt / 2.0f - currentTime);

            /* [5]: RF3 Pulse */
            this->pluginRF(
                this->rectRF(this->m_rf3.rfFlipAngle, this->m_rf3.rfDt, this->m_rf3.rfPhase, this->m_rf3.rfFreq));

            /* [7]: Shift Gradient2 */
            this->pluginGradient(this->m_shiftG3XAmp, this->m_shiftG3YAmp, 0, false, this->m_shiftG3.duration);
            //this->pluginGradient(0, shotidx * this->m_dGyAmp, 0, false, this->m_samplingDt);

            /* [16]: Relaxation */
            //this->pluginRelaxation(
            //    this->m_lastRelaxTime - this->m_rf3.middleStamp - this->m_rf3.rfDt / 2.0f - this->m_shiftG3.duration - this->m_samplingDt + shotidx * (this->m_esp / this->m_shotNum));
            //currentTime = this->m_lastRelaxTime + shotidx * (this->m_esp / this->m_shotNum);

            this->pluginRelaxation(
                this->m_lastRelaxTime - this->m_rf3.middleStamp - this->m_rf3.rfDt / 2.0f - this->m_shiftG3.duration - this->m_samplingDt);
            currentTime = this->m_lastRelaxTime;

            /* [17]: Sampling */
            for (int phase_index = 0; phase_index < this->m_ETL; ++phase_index)
            {
                if (phase_index % 2 == 0)
                {
                    tmpDGxAmp = -this->m_dGxAmp;
                }
                else
                {
                    tmpDGxAmp = this->m_dGxAmp;
                }

                this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);
                for (int freq_index = 0; freq_index < this->m_xN; ++freq_index)
                {
                    this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * this->m_samprate);
                }
                this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);

                this->pluginGradient(0, this->m_shotNum * this->m_dGyAmp, 0, false, this->m_samplingDt);
            }
            currentTime = currentTime + (this->m_esp * this->m_ETL);

            /* [16]: Relaxation */
            this->pluginRelaxation(this->m_lastRelaxTime2 - this->m_samplingDt);
            this->pluginGradient(0, -this->m_dGyAmp * this->Shiftrewind, 0, false, this->m_samplingDt);

            currentTime = currentTime + this->m_lastRelaxTime2;

            /* [17]: Sampling */
            for (int phase_index = 0; phase_index < this->m_ETL; ++phase_index)
            {
                if (phase_index % 2 == 0)
                {
                    tmpDGxAmp = this->m_dGxAmp;
                }
                else
                {
                    tmpDGxAmp = -this->m_dGxAmp;
                }

                this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);
                for (int freq_index = 0; freq_index < this->m_xN; ++freq_index)
                {
                    this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * this->m_samprate);
                }
                this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);

                this->pluginGradient(0, this->m_shotNum * this->m_dGyAmp, 0, false, this->m_samplingDt);
            }

            currentTime = currentTime + (this->m_esp * this->m_ETL);

            /* [16]: Relaxation */
            this->pluginRelaxation(
                this->m_tr - currentTime);
            this->pluginRecoverxy(); 
    }

    for (int shotId = 0; shotId < this->m_shotNum; shotId++)
    {

        shotidx = shotId - this->m_shotNum / 2.0f + 1;
        budaidx = this->m_shotNum - shotidx * 2.0f + 1;
        budatime = budaidx * this->m_esp / this->m_shotNum;

        /* [1]: RF1 Pulse */
        this->pluginRF(
            this->rectRF(this->m_rf1.rfFlipAngle, this->m_rf1.rfDt, this->m_rf1.rfPhase, this->m_rf1.rfFreq));
        currentTime = this->m_rf1.middleStamp + this->m_rf1.rfDt / 2.0f;

        /* [2]: Relaxtion */
        this->pluginRelaxation(this->m_shiftG1.middleStamp - this->m_shiftG1.duration / 2.0f - currentTime);

        /* [3]: Shift Gradient1 */
        this->pluginGradient(this->m_shiftG1XAmp, this->m_shiftG1YAmp, 0, false, this->m_shiftG1.duration);
        currentTime = this->m_shiftG1.middleStamp + this->m_shiftG1.duration / 2.0f;

        /* [4]: Relaxtion */
        this->pluginRelaxation(this->m_rf2.middleStamp - this->m_rf2.rfDt / 2.0f - currentTime);

        /* [1]: RF2 Pulse */
        this->pluginRF(
            this->rectRF(this->m_rf2.rfFlipAngle, this->m_rf2.rfDt, this->m_rf2.rfPhase, this->m_rf2.rfFreq));
        currentTime = this->m_rf2.middleStamp + this->m_rf2.rfDt / 2.0f;

        /* [2]: Relaxtion */
        this->pluginRelaxation(this->m_shiftG2.middleStamp - this->m_shiftG2.duration / 2.0f - currentTime);

        /* [3]: Shift Gradient1 */
        this->pluginGradient(this->m_shiftG2XAmp, this->m_shiftG2YAmp, 0, false, this->m_shiftG2.duration);
        currentTime = this->m_shiftG2.middleStamp + this->m_shiftG2.duration / 2.0f;

        /* [4]: Relaxtion */
        this->pluginRelaxation(this->m_rf3.middleStamp - this->m_rf3.rfDt / 2.0f - currentTime);

        /* [5]: RF3 Pulse */
        this->pluginRF(
            this->rectRF(this->m_rf3.rfFlipAngle, this->m_rf3.rfDt, this->m_rf3.rfPhase, this->m_rf3.rfFreq));

        /* [7]: Shift Gradient2 */
        this->pluginGradient(this->m_shiftG3XAmp, this->m_shiftG3YAmp, 0, false, this->m_shiftG3.duration);
        this->pluginGradient(0, shotidx * this->m_dGyAmp, 0, false, this->m_samplingDt);

        /* [16]: Relaxation */
        this->pluginRelaxation(
            this->m_lastRelaxTime - this->m_rf3.middleStamp - this->m_rf3.rfDt / 2.0f - this->m_shiftG3.duration - this->m_samplingDt + shotidx * (this->m_esp / this->m_shotNum));
        currentTime = this->m_lastRelaxTime + shotidx * (this->m_esp / this->m_shotNum);

        /* [17]: Sampling */
        for (int phase_index = 0; phase_index < this->m_ETL; ++phase_index)
        {
            if (phase_index % 2 == 0)
            {
                tmpDGxAmp = -this->m_dGxAmp;
            }
            else
            {
                tmpDGxAmp = this->m_dGxAmp;
            }

            this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);
            for (int freq_index = 0; freq_index < this->m_xN; ++freq_index)
            {
                this->pluginGradient(tmpDGxAmp, 0, 0, true, this->m_samplingDt * this->m_samprate);
            }
            this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);

            this->pluginGradient(0, this->m_shotNum * this->m_dGyAmp, 0, false, this->m_samplingDt);
        }
        currentTime = currentTime + (this->m_esp * this->m_ETL);

        /* BUDA */
        this->pluginRelaxation(this->m_lastRelaxTime2-this->m_samplingDt * 2.0);
        this->pluginGradient(0, -this->m_dGyAmp * 16, 0, false, this->m_samplingDt);
        this->pluginGradient(0, budaidx * this->m_dGyAmp, 0, false, this->m_samplingDt);

        currentTime = currentTime + this->m_lastRelaxTime2;

        /* [17]: Sampling */
        for (int phase_index = 0; phase_index < this->m_ETL; ++phase_index)
        {
            if (phase_index % 2 == 0)
            {
                tmpDGxAmp = this->m_dGxAmp;
            }
            else
            {
                tmpDGxAmp = -this->m_dGxAmp;
            }

            this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);
            for (int freq_index = 0; freq_index < this->m_xN; ++freq_index)
            {
                this->pluginGradient(tmpDGxAmp, 0, 0, true, this->m_samplingDt * this->m_samprate);
            }
            this->pluginGradient(tmpDGxAmp, 0, 0, false, this->m_samplingDt * 0.5 * (1 - this->m_samprate) * this->m_xN);

            this->pluginGradient(0, -this->m_shotNum * this->m_dGyAmp, 0, false, this->m_samplingDt);
        }

        currentTime = currentTime + (this->m_esp * this->m_ETL);

        /* [16]: Relaxation */
        this->pluginRelaxation(
            this->m_tr - currentTime);
        this->pluginRecoverxy();
    }

    return true;
}

double SeqGREOLEDMS3Dp3_BUDA::calculateGraAmp(double dt, double gAmpCoeff, int dType)
{
    double graAmp = 0;
    switch (dType)
    {
    case 0:
    {
        graAmp = gAmpCoeff * this->m_dGxAmp * dt / this->m_samplingDt;
        break;
    };
    case 1:
    {
        graAmp = gAmpCoeff * this->m_dGyAmp * dt / this->m_blipT;
        break;
    };
    };

    return graAmp;
}

void SeqGREOLEDMS3Dp3_BUDA::initGREOLEDMS3Dp3_BUDAParameters(int fileID)
{
    if (this->m_shiftUseBlipT)
    {
        this->m_shiftG1.duration = this->m_samplingDt;
        this->m_shiftG2.duration = this->m_samplingDt;
        this->m_shiftG3.duration = this->m_samplingDt;
    }
    if (fileID % (this->slice_num) == 1)
    {
        this->randomShiftGra(3);
    }

    if (this->m_shiftGraFlag == true)
    {
        this->m_shiftG1XAmp = this->calculateGraAmp(this->m_shiftG1.duration, this->m_shiftG1.xGradient + this->getShiftGra(1, 1), 0);
        this->m_shiftG2XAmp = this->calculateGraAmp(this->m_shiftG2.duration, this->m_shiftG2.xGradient + this->getShiftGra(2, 1), 0);
        this->m_shiftG3XAmp = this->calculateGraAmp(this->m_shiftG3.duration, this->m_shiftG3.xGradient + this->getShiftGra(3, 1), 0);

        this->m_shiftG1YAmp = this->calculateGraAmp(this->m_shiftG1.duration, this->m_shiftG1.yGradient + this->getShiftGra(1, 2), 1);
        this->m_shiftG2YAmp = this->calculateGraAmp(this->m_shiftG2.duration, this->m_shiftG2.yGradient + this->getShiftGra(2, 2), 1);
        this->m_shiftG3YAmp = this->calculateGraAmp(this->m_shiftG3.duration, this->m_shiftG3.yGradient + this->getShiftGra(3, 2), 1);
    }
    else
    {
        this->m_shiftG1XAmp = this->calculateGraAmp(this->m_shiftG1.duration, this->m_shiftG1.xGradient, 0);
        this->m_shiftG2XAmp = this->calculateGraAmp(this->m_shiftG2.duration, this->m_shiftG2.xGradient, 0);
        this->m_shiftG3XAmp = this->calculateGraAmp(this->m_shiftG3.duration, this->m_shiftG3.xGradient, 0);

        this->m_shiftG1YAmp = this->calculateGraAmp(this->m_shiftG1.duration, this->m_shiftG1.yGradient, 1);
        this->m_shiftG2YAmp = this->calculateGraAmp(this->m_shiftG2.duration, this->m_shiftG2.yGradient, 1);
        this->m_shiftG3YAmp = this->calculateGraAmp(this->m_shiftG3.duration, this->m_shiftG3.yGradient, 1);
    }

}

void SeqGREOLEDMS3Dp3_BUDA::randomShiftGra(int loopi)
{
    if (this->m_shiftGraFlag == false)
    {
        return;
    }
    float gxGra = 0, gyGra = 0, gzGra = 0;
    std::uniform_real_distribution<float> xDistri(this->m_xShiftGra.minG * this->m_shiftG1.xGradient, this->m_xShiftGra.maxG * this->m_shiftG1.xGradient);
    std::uniform_real_distribution<float> yDistri(this->m_yShiftGra.minG * this->m_shiftG1.yGradient, this->m_yShiftGra.maxG * this->m_shiftG1.yGradient);
    std::uniform_real_distribution<float> zDistri(this->m_zShiftGra.minG, this->m_zShiftGra.maxG);

    gxGra = xDistri(this->m_randomEng);
    gyGra = yDistri(this->m_randomEng);
    gzGra = zDistri(this->m_randomEng);

    this->m_randv.at(0) = gxGra;
    this->m_randv.at(1) = gyGra;
    this->m_randv.at(2) = gzGra;

    xDistri.param(std::uniform_real_distribution<float>::param_type(this->m_xShiftGra.minG * this->m_shiftG2.xGradient, this->m_xShiftGra.maxG * this->m_shiftG2.xGradient));
    yDistri.param(std::uniform_real_distribution<float>::param_type(this->m_yShiftGra.minG * this->m_shiftG2.yGradient, this->m_yShiftGra.maxG * this->m_shiftG2.yGradient));
    zDistri.param(std::uniform_real_distribution<float>::param_type(this->m_zShiftGra.minG, this->m_zShiftGra.maxG));
    gxGra = xDistri(this->m_randomEng);
    gyGra = yDistri(this->m_randomEng);
    gzGra = zDistri(this->m_randomEng);

    this->m_randv.at(3) = gxGra;
    this->m_randv.at(4) = gyGra;
    this->m_randv.at(5) = gzGra;

    xDistri.param(std::uniform_real_distribution<float>::param_type(this->m_xShiftGra.minG * this->m_shiftG3.xGradient, this->m_xShiftGra.maxG * this->m_shiftG3.xGradient));
    yDistri.param(std::uniform_real_distribution<float>::param_type(this->m_yShiftGra.minG * this->m_shiftG3.yGradient, this->m_yShiftGra.maxG * this->m_shiftG3.yGradient));
    zDistri.param(std::uniform_real_distribution<float>::param_type(this->m_zShiftGra.minG, this->m_zShiftGra.maxG));
    gxGra = xDistri(this->m_randomEng);
    gyGra = yDistri(this->m_randomEng);
    gzGra = zDistri(this->m_randomEng);

    this->m_randv.at(6) = gxGra;
    this->m_randv.at(7) = gyGra;
    this->m_randv.at(8) = gzGra;
}

float SeqGREOLEDMS3Dp3_BUDA::getShiftGra(int time, int direc)
{
    int index = (time - 1) * 3 + direc - 1;
    return this->m_randv.at(index);
}