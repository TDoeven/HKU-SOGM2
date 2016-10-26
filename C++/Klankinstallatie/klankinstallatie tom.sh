#! /bin/bash


echo "Please enter the name of your project"
read input_name

# check if the directory name doees not already exist
if [ ! -d "$input_name/" ] ; then 
  mkdir -p "$input_name/";
  cd $input_name;

# create directory's where the files will be stored later
  mkdir "Puur";
  mkdir "Reverb";
  mkdir "Distorted";
  mkdir "Anders";
  mkdir "Temp";

# recording audio, but trim it untill I have an empty sound file left. I
# will use it later to store audio in it, so like this the files dont have
# to exist before executing the programm
  rec output.wav trim 0.0 0.0
  rec buffer.wav trim 0.0 0.0
  rec empty.wav trim 0.0 0.0
  rec outputfinal.wav trim 0.0 0.0
  cd ..
  sleep 0.5
  echo "Directory $input_name has been made";
  sleep 0.5

# if the directory already exists it says "already in use" and restarts the
# programm, so you get the first question again.
else 
  echo "$input_name is already in use";
  "Klankinstallatie tom.sh"
  sleep 0.5
fi

# i is created for the name, the name of the file will be for example Puur
# i and i stands for which file it is
i=1;

# for all the files in the directory samples_orgineel that have the
# extension .mp3
for file in samples_origineel/*.mp3
do

# I take every file and first only trim, fade and normalize it, then in the
# second sox line i also add an reverb, in the third line I use an
# overdrive and in the last one I go crazy. The files are stored in the
# directory $input_name which is the project name you chose before, and
# then in directory's Puur Reverb Distorted and Anders, which I created.

        sox $file "$input_name/Puur/Puur ${i}.wav" gain -6 trim 1.0 5.0 \
	fade 0.1 5.0 0.1 norm -6

	sox $file "$input_name/Reverb/Reverb ${i}.wav" gain -6 trim 1.0 4.0 fade \
	0.1 4.0 0.1 reverb norm -6

	sox $file "$input_name/Distorted/Distorted ${i}.wav" gain -6 trim 1.0 2.0 \
	fade 0.1 2.0 0.1 overdrive 10 norm -6

	sox $file "$input_name/Anders/Anders ${i}.wav" gain -6 trim 1.0 6.0 \
	fade 0.1 6.0 0.1 overdrive 10 reverb pitch 400 norm -6

	echo "Sample $i is being processed!"

# here i counts up, so files will be calles Puur 1, Puur 2 and so on.
	i=$((i+1));

done

# I first go to the directory $input_name, then make the variable BASEDIR,
# which is the directory I am in currently, and then I cp, or copy, every
# file in Puur Reverb Distorted and Anders to the directory Temp
cd $input_name;
BASEDIR=`pwd`
cp -R "$BASEDIR/Puur/" "$BASEDIR/Temp"
cp -R "$BASEDIR/Reverb/" "$BASEDIR/Temp"
cp -R "$BASEDIR/Distorted/" "$BASEDIR/Temp"
cp -R "$BASEDIR/Anders/" "$BASEDIR/Temp"


# I ask if the operator wants a mashup as well, with possibility's Y and N.
# When N is entered, the programm exits. If anything but N or Y is entered,
# the same question is asked again after telling only Y and N is possible.
# When Y is answered, the task proceeds
while true; do
    read -p "Do you want a mashup of the files (Y/N)?
    " answer
    case $answer in
    	[Nn]* ) echo "Thanks for using the programm!"; 
	  `rm shorted.wav`
	  `rm buffer.wav`
	  `rm output.wav`
	  `rm empty.wav`
	  `rm -rf Temp`
	  exit;;
	![Nn]* ) echo "Please answer y or n.";;
        [Yy]* ) echo "Processing..";
	sleep 0.7

# The operator can choose how long the mashup is going to be
	echo "How long should the mashup be?"
	read seconds;
	sleep 0.5

# Here comes the Temp folder in to play. The Temp folder contains every
# sample. The folder is put in a random order, and then a random number
# between 0 and 1 (seconds) is picked. This is how long the sample in the
# mashup is going to be. The samples are glued together untill the output
# is greater then $seconds, how long you wanted to mashup to be. If it
# exceeds that number, the programm will exit and remove all non essential
# files.
for file in Temp/*.wav
do
	RANDOMNUMBER=$(echo "scale=4 ; (( ${RANDOM}/32767) + 1) " | bc -l )
	echo "$LENGTH seconds of $seconds seconds processed."
	sox "$file" -r 44.1k -c 2 shorted.wav trim 0 $RANDOMNUMBER
	sox shorted.wav buffer.wav output.wav
	sox output.wav buffer.wav

	LENGTHTEMP=$(soxi -D output.wav)
	LENGTH=${LENGTHTEMP%.*}
	if (( "$LENGTH" >= "$seconds" ))
	then
		sox output.wav outputfinal.wav trim 0.0 $LENGTH
		`rm shorted.wav`
		`rm buffer.wav`
		`rm output.wav`
		`rm empty.wav`
		`rm -rf Temp`
		echo "Your file is finished!"
		echo "Bye!"
		exit 0
		break;
	fi
     done
  esac
done
