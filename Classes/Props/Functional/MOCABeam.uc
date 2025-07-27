//================================================================================
// MOCABeam.
//================================================================================

class MOCABeam extends Actor;

function TurnDynamicLightOn()
{
  // LightType = 1;
  LightType = LT_Steady;
  // LightEffect = 13;
  LightEffect = LE_NonIncidence;
  LightBrightness = 162;
  LightHue = 153;
  LightSaturation = 0;
  LightRadius = 4;
  LightRadiusInner = 0;
}

function TurnDynamicLightOff()
{
  // LightType = 0;
  LightType = LT_None;
  // LightEffect = 0;
  LightEffect = LE_None;
  LightBrightness = 0;
  LightHue = 0;
  LightSaturation = 0;
  LightRadius = 0;
  LightRadiusInner = 0;
}