package audiomixer.core
{
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class AudioMixer implements IAudioInput
	{
		
		public static const SOUND_LOOP_NUMBER:int = 4096;
		
		private var slots:Vector.<MixerChannel>;
		private var bytes:ByteArray;
		private var timer:Timer;
		private var m_master:MixerChannel;
		private var sound:Sound;
		
		public function AudioMixer()
		{
			var i:int;
			
			slots = new Vector.<MixerChannel>;
			
			m_master = new MixerChannel();
			m_master.nextslot = this;
			
			m_master.preVolume.db = 0;
			m_master.postVolume.db = -6;
			this.add(m_master);
			
			
			bytes = new ByteArray();
			for (i = 0; i < AudioMixer.SOUND_LOOP_NUMBER; i++) {
				bytes.writeFloat(0);
				bytes.writeFloat(0);
			}
			
			sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			sound.play();
			
		}
		
		public function get masterChannel():MixerChannel {
			return m_master;
		}
		
		public function add(mixerSlot:MixerChannel):int {
			if (!mixerSlot.nextslot) {
				mixerSlot.nextslot = m_master;
			}
			return slots.push(mixerSlot) - 1;
		}
		
		public function input(packet:AudioPacket):void {
			var i:int; 
			var signal:AudioSignal;
			
			
			bytes.position = 0;
			for (i = 0; i < AudioMixer.SOUND_LOOP_NUMBER; i++) {
				signal = packet.get(i);
				bytes.writeFloat(signal.l);
				bytes.writeFloat(signal.r);
			}
		}
		
		private function onSampleData(e:SampleDataEvent):void {
			var slot:MixerChannel;
			var i:int;
			
			for each (slot in slots) {
				slot.input(new AudioPacket());
			}
			
			bytes.position = 0;
			for (i = 0; i < AudioMixer.SOUND_LOOP_NUMBER; i++) {
				e.data.writeFloat(bytes.readFloat());
				e.data.writeFloat(bytes.readFloat());
			}
			
			
		}
	}
}