using UnityEngine;
using UnityEngine.Rendering;
namespace CustomRenderPipeline
{
    public class SpaceRunPipelineRender : RenderPipeline
    {
        CameraRenderer _cameraRenderer = new CameraRenderer();

        public SpaceRunPipelineRender()
        {
            GraphicsSettings.lightsUseLinearIntensity = true;
        }

        protected override void Render(ScriptableRenderContext context, Camera[] cameras)
        {
            CamerasRender(context, cameras);
        }

        private void CamerasRender(ScriptableRenderContext context, Camera[] cameras)
        {
            foreach (var camera in cameras)
            {
                _cameraRenderer.Render(context, camera);
            }
        }

    }
}

