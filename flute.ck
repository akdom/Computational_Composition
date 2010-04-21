// STK Flute
/*
jetDelay: 0.567296 
jetReflection: 0.292315 
endReflection: 0.983638 
noiseGain: 0.899821 
vibratoFreq: 5.681105 
vibratoGain: 0.410392 
breath pressure: 0.249643

jetDelay: 0.238414 
jetReflection: 0.852602 
endReflection: 0.758460 
noiseGain: 0.423868 
vibratoFreq: 7.711333 
vibratoGain: 0.268799 
breath pressure: 0.646396 

*/

// patch
Flute flute1=> PoleZero f1 => JCRev r1 => dac.left;
.75 => r1.gain;
.05 => r1.mix;
.99 => f1.blockZero;

flute1.clear( 1.0 );
0.000005 => flute1.jetDelay;
0.400000 => flute1.jetReflection;
0.000000 => flute1.endReflection;
0.000000 => flute1.noiseGain;
0.300000 => flute1.vibratoFreq;
0.100000 => flute1.vibratoGain;
0.800000 => flute1.pressure;


Flute flute2=> PoleZero f2 => JCRev r2 => dac.right;
.75 => r2.gain;
.05 => r2.mix;
.99 => f2.blockZero;

flute2.clear( 1.0 );
0.001108 => flute2.jetDelay;
0.500000 => flute2.jetReflection;
0.000000 => flute2.endReflection;
0.000000 => flute2.noiseGain;
0.500000 => flute2.vibratoFreq;
0.100000 => flute2.vibratoGain;
0.800000 => flute2.pressure;

// our notes
[ 61, 63, 65, 66, 68 ] @=> int notes[];

// infinite time-loop
while( true )
{
    // clear

    // set
	/*
    0.167296 => flute.jetDelay;
    0.892315 => flute.jetReflection;
    0.763638 => flute.endReflection;
    0.299821 => flute.noiseGain;
    7.681105 => flute.vibratoFreq;
    0.310392 => flute.vibratoGain;
    0.579643 => flute.pressure;
	*/

    // print
    <<< "---", "" >>>;
    // factor
    Std.rand2f( .75, 2 ) => float factor;

    for( int i; i < notes.cap(); i++ )
    {
        play( 12 + notes[i], Std.rand2f( .6, .9 ) );
        300::ms * factor => now;
    }
}

// basic play function (add more arguments as needed)
fun void play( float note, float velocity )
{
    // start the note
    Std.mtof( note ) => flute1.freq;
    Std.mtof( note ) => flute2.freq;
    velocity => flute1.noteOn;
    velocity => flute2.noteOn;
}
