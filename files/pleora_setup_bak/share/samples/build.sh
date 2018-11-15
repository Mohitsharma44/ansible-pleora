SAMPLES=" \
  ConfigurationReader \
  DeviceFinder \
  GenICamParameters \
  MulticastMaster \
  MulticastSlave \
  MultiSource \
  PvPipelineSample \
  PvStreamSample \
  DeviceSerialPort \
  TransmitTestPattern \
  ConnectionRecovery \
  TapReconstruction \
  eBUSPlayer \
  eBUSPlayer \
  DualSource \
  TransmitProcessedImage \
  ImageProcessing \
"

for SAMPLE in $SAMPLES; do
  make -C $SAMPLE
done

