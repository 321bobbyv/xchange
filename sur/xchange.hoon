|%
::
+$  act
  $%  [%etherscan-key key=@t]
      [%add-my-ad id=@t note=advert]
      [%add-all-ad id=@t note=advert]
      [%del-my-ad id=@t note=advert]
      [%del-all-ad id=@t note=advert]
      [%add-alert alert-id=@t alertinfo=alert]
      [%del-alert alert-id=@t alertinfo=alert]
      [%add-fav ship=@p comment=@t]
      [%del-fav ship=@p comment=@t]
      [%add-avoid ship=@p note=my-avoid]
      [%del-avoid ship=@p note=my-avoid]
  ==
  :: Distribution ship management actions
+$  distribution-ship-action
  $%  [%add-participant ship=@p]
      [%remove-participant ship=@p]
      [%debug %state]
      [%reset-distribution ~]
      [%manual-add-ship ship=@p]
  ==
+$  sort-state
  $:  column=@t       :: which column to sort by ('title', 'date', 'type', etc.)
      ascending=?     :: %.y = ascending, %.n = descending
  ==
+$  advert
  $:  ad-title=@t
      when=@da
      type=@t
      price=(unit @t)
      timezone=(unit @t)
      contact=@t
      ship=@p
      body=@t
      active=?
  ==
  +$  advert1
  $:  ad-title=@t
      when=@da
      type=@t
      price=(unit @t)
      timezone=(unit @t)
      contact=@t
      ship=@p
      body=@t
      active=?
      image1=(unit image-info1)::[filename1 content-type bytes@ud data @ud]
      image2=(unit image-info2)
  ==
  +$  image-info1
  $:  filename1=@t
      content-type1=@t
      body1=octs::[legnth in bytes and data]
  ==
  +$  image-info2
  $:  filename2=@t
      content-type2=@t
      body2=octs
  ==
+$  alert
  $:  alert-title=@t
      ad-title=@t
      when=@da
      type=@t
      price=(unit @t)
      timezone=(unit @t)
      contact=@t
      ship=@t
      body=@t
      active=?
  ==
+$  alert-result
    $:  ad-title=@t
        when=@da
        type=@t
        price=(unit @t)
        timezone=(unit @t)
        contact=@t
        ship=@p
        body=@t
        active=?
        alert-id=@t
    ==
+$  my-favorite
    $:  ship=@p
        comment=@t
  ==
+$  my-avoid
    $:  comment=@t
        block=?
  ==
::
+$  page  [id=@t advert]
+$  mywallet  [@t]
+$  balance  [@ud]
+$  listings  (map id=@t advert)
+$  listings1  (map id=@t advert1)
+$  mylistings  (map id=@t advert)
+$  mylistings1  (map id=@t advert1)
+$  alerts  (map alert-id=@t alert)
+$  alert-results  (map ad-id=@t alert-result)
+$  my-favorites  (map ship=@p comment=@t)
+$  my-avoids  (map ship=@p my-avoid)
+$  xchange-ships  (set @p) ::structure to track known xchange ships
::
+$  action
  $%  [%ad-update =listings]
      [%delete id=@t]
  ==
+$  action1
  $%  [%ad-update =listings1]
      [%delete id=@t]
  ==
+$  distribution-action
  $%  [%participants ships=(set @p)]
      [%add-participant ship=@p]
      [%remove-participant ship=@p]
  ==
+$  message-pals  @t
+$  message-alerts  @t
+$  message-myads  @t
+$  message-settings  @t
+$  maxpic-size  @ud
+$  maxad-timeout  @dr
+$  maxapp-size  @ud
--
