from pydub import AudioSegment
import soundfile as sf
import os

bitrate = "224k"
output = "wav"

for root, dirs, files in os.walk(os.getcwd()):
    for file in files:
        if file[-4:] == ".wav":
            abspath = os.path.join(root, file)

            #Import and export file to convert to standard PCM16 encoding, so ffmpeg can read it
            data, samplerate = sf.read(abspath)
            sf.write(abspath, data, samplerate)

            if output == "mp3":
                print("Converting " + os.path.relpath(abspath) + " to mp3")

                AudioSegment.from_wav(abspath).export(abspath[:-4] + ".mp3", format="mp3", bitrate=bitrate)
                os.remove(abspath)
            elif output == "wav":
                print("Converting " + os.path.relpath(abspath) + " to mono")

                AudioSegment.from_wav(abspath).set_channels(1).export(abspath, format="wav")

input("Finished, press enter to close...")