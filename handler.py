import os
import base64
import io
import torch
import soundfile as sf
import runpod
from ace_step import ACEStepXL

# Global model instance
MODEL = None

def load_model():
    global MODEL
    if MODEL is None:
        print("📥 Loading ACE-Step 1.5 XL...")
        MODEL = ACEStepXL.from_pretrained(
            "ace-step/ace-step-1.5-xl",
            device_map="cuda",
            torch_dtype=torch.bfloat16
        )
    return MODEL

def handler(event):
    model = load_model()
    job_input = event["input"]
    
    prompt = job_input.get("prompt")
    lyrics = job_input.get("lyrics", "")
    duration = int(job_input.get("duration", 30)) # seconds
    
    if not prompt:
        return {"error": "prompt is required"}

    try:
        print(f"🎵 Generating {duration}s of audio for: {prompt}")
        audio, sr = model.generate(
            prompt=prompt,
            lyrics=lyrics,
            duration=duration,
            guidance_scale=7.5
        )

        # Encode to Base64
        buffer = io.BytesIO()
        sf.write(buffer, audio.cpu().numpy(), sr, format='WAV')
        audio_b64 = base64.b64encode(buffer.getvalue()).decode('utf-8')

        return {
            "audio": f"data:audio/wav;base64,{audio_b64}",
            "duration": duration,
            "sample_rate": sr
        }

    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    runpod.serverless.start({"handler": handler})
