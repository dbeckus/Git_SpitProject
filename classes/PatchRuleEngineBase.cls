/*
* This class is base class of PatchRuleEngine.
*/
public virtual class PatchRuleEngineBase
{
  //returns the matched patch
  public virtual Match match(Target t)
  {
    Match result = null;
    return result;
  }

  @testvisible
  protected Boolean opIn(String value, Set<String> targetSet)
  {
    value = (value == null) ? null : value.toLowerCase();
    return targetSet.contains(value);
  }
  @testvisible
  protected Boolean opInRange(String value, String targetLow, String targetHigh)
  {
    value = (value == null) ? '' : value.toLowerCase();
    targetLow = (targetLow == null) ? '' : targetLow.toLowerCase();
    targetHigh = (targetHigh == null) ? '' : targetHigh.toLowerCase();
    if(value.length() < targetLow.length() || value.length() < targetHigh.length())
    {
      return false;
    }
    else
    {
      return value.substring(0, targetLow.length()) >= targetLow && value.substring(0, targetHigh.length()) <= targetHigh;
    }
  }
  @testvisible
  protected Boolean opEqual(String value, String target)
  {
    return value == target || (String.IsBlank(target) && String.isBlank(value));
  }
  @testvisible
  protected Boolean opStart(String value, Set<String> targetSet)
  {
    value = (value == null) ? '' : value.toLowerCase();
    for(String t : targetSet)
    {
      if(value.startsWith(t))
      {
         return true;
      }
    }
    return false;
  }
  @testvisible
  protected Boolean opEnd(String value, Set<String> targetSet)
  {
    value = (value == null) ? '' : value.toLowerCase();
    for(String t : targetSet)
    {
      if(value.endsWith(t))
      {
         return true;
      }
    }
    return false;
  }
  @testvisible
  protected Boolean opContain(String value, String target)
  {
    value = (value == null) ? '' : value.toLowerCase();
    target = (target == null) ? '' : target.toLowerCase();
    return value.contains(target);
  }
  @testvisible
  protected Boolean opZipcode(String zipcode, String target)
  {
    zipcode = (zipcode == null) ? '' : zipcode.replaceAll('\\s', '');
    if(zipcode.contains('-'))
    {
      zipcode = zipcode.substring(0, zipcode.indexOf('-'));
    }
    target = (target == null) ? '' : target.replaceAll('\\s', '');
    for(String segment : target.split(','))
    {
      if(!segment.contains('~'))
      {
        if(zipcode.startsWith(segment))
        {
          return true;
        }
      }
      else
      {
        String[] range = segment.split('~');
        if(zipcode >= range[0] && zipcode <= range[1])
        {
          return true;
        }
      }
    }
    return false;
  }

  public class Target
  {
    public String Company { get; set; }
    public String EmailDomain { get; set; }
    public String Country { get; set; }
    public String ZipCode { get; set; }
    public String State { get; set; }
    public String Industry { get; set; }
    public Boolean Locked { get; set; }
  }

  public class Match
  {
      public Match(Id patchId, List<Id> overlays)
      {
          this.PatchId = patchId;
          this.OverlayMatches = overlays;
      }

      public Id PatchId { get; set; }
      public List<Id> OverlayMatches { get; set; }
  }
}