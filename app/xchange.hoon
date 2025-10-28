/-  *xchange
/-  hark
/+  default-agent, dbug, agentio, sigil
|%
  +$  versioned-state
      $%  [%0 state-zero]
    ==
  +$  state-zero
    $:  %0::remove
      mywallet=@t
      balance=@ud
      etherscankey=@t
      listings=(map id=@t advert)
      listings1=(map id=@t advert1)
      mylistings=(map id=@t advert)
      mylistings1=(map id=@t advert1)
      alerts=(map alert-id=@t alert)
      my-favorites=(map ship=@p comment=@t)
      my-avoids=(map ship=@p my-avoid)
      alert-results=(map ad-id=@t alert-result)
      message-pals=@t
      message-alerts=@t
      message-myads=@t
      message-settings=@t
      sort-state=[column=@t ascending=?]
      xchange-ships=(set @p)
      maxpic-size=@ud
      maxad-timeout=@dr
      maxapp-size=@ud
    ==
    ::
  +$  card  card:agent:gall
  ++  get-date
    |=  date=@da
      ^-  @t
        =/  year  (crip (a-co:co y:(yore date)))
        =/  month  `@t`(cat 3 '.' (scot %ud m:(yore date)))
        =/  day  `@t`(cat 3 '.' (scot %ud d:t:(yore date)))
        =/  hour  `@t`(cat 3 ' ' (scot %ud h:t:(yore date)))
        =/  minute  ?:  (lth (lent (trip (scot %ud m:t:(yore date)))) 2)
          `@t`(cat 3 ':' (cat 3 '0' (scot %ud m:t:(yore date))))
        `@t`(cat 3 ':' (scot %ud m:t:(yore date)))
        `@t`(cat 3 year (cat 3 month (cat 3 day (cat 3 hour minute))))
  ::
--
%-  agent:dbug
=|  [%0 state-zero]
=*  state  -
^-  agent:gall
::
=<
::main app
  |_  =bowl:gall
    +*  this  .
        def   ~(. (default-agent this %|) bowl)
        io    ~(. agentio bowl)
        is    ~(. +> bowl)
        ::
    ++  on-init
        =/  new-maxpic-size  2
        =/  new-maxad-timeout  ~d180
        =/  new-maxapp-size  2.000
        =/  new-timer  (add now.bowl ~s31)
        ::~&  [%init-timer-set new-timer]
        ^-  (quip card _this)
        =/  distribution-ship  ~tabdyl
        :_  this(maxpic-size new-maxpic-size, maxad-timeout new-maxad-timeout, maxapp-size new-maxapp-size)
        :~  [%pass /bind-url %arvo %e %connect `/apps/xchange %xchange]
            [%pass /participants %agent [distribution-ship %xchange] %watch /participants]
            [%pass /xchange/timer %arvo %b %wait new-timer]
        ==
    ++  on-save
        ^-  vase
        !>(state)
        ::
    ++  on-load
        |=  ole=vase
        =/  old=versioned-state  !<(versioned-state ole)
        |-
        ?-    -.old
            %0
        %-  (slog leaf+"%xchange-reloaded" ~)
        `this(state old)
        ==
        ::
    ++  on-poke
      |=  [=mark =vase]
      ::~&  [%bowl bowl]
      ?>  =(our.bowl src.bowl)
    ^-  (quip card _this)
    ?>  =(our.bowl src.bowl)
    ?+    mark  (on-poke:def mark vase)
        %xchange-act
      =/  vaz=act  !<(act vase)
      =^  cards  state
        ?-  -.vaz
          %etherscan-key            (eth-key:gilt:is +.vaz)
          %add-my-ad               (add-myad:gilt:is +.vaz)
          %add-all-ad              (add-allad:gilt:is +.vaz)
          %del-my-ad              (del-myad:gilt:is +.vaz)
          %del-all-ad              (del-allad:gilt:is +.vaz)
          %add-alert              (add-alert:gilt:is +.vaz)
          %del-alert              (del-alert:gilt:is +.vaz)
          %add-fav                (add-favorite:gilt:is +.vaz)
          %del-fav                (del-favorite:gilt:is +.vaz)
          %add-avoid               (add-avoid:gilt:is +.vaz)
          %del-avoid               (del-avoid:gilt:is +.vaz)
        ==
      [cards this]
      %subscribe-request
        =/  target-ship  !<(ship vase)
        :_  this
        :~  [%pass /ad-updates/(scot %p target-ship) %agent [target-ship %xchange] %watch /ad-updates]
        ==
        ::
      %handle-http-request
      =/  req  !<  (pair @ta inbound-request:eyre)  vase
      ::~&  [%req req]
      =/  eny  (crip (a-co:co eny.bowl))
      =/  purl  (rash url.request.q.req ;~(plug apat:de-purl:html yque:de-purl:html))
      ::~&  [%purl purl]
      =/  web-address  +.q.purl
      ::~&  [%web-address web-address]
      =/  purl1  ?~  +.purl  ~  %a
      =/  purl-pair  ?:  =(purl1 %a)  -.+.purl  ['n' 'n']
            :: Handle static picture file requests (xchange logo)- 
      ?:  ?&  =(method.request.q.req %'GET')
          ?=([%xchange %img %xchange-logo *] +.q.purl)
          ==
      [(serve-static-file:static /img/xchange-logo/png req our.bowl now.bowl) this]
      ::
      :::: Handle static picture file requests (xchange header)- 
      ?:  ?&  =(method.request.q.req %'GET')
          ?=([%xchange %img %xchange-header *] +.q.purl)
          ==
      [(serve-static-file:static /img/xchange-header/png req our.bowl now.bowl) this]
      ::::
      ?:  ?&  =(method.request.q.req %'GET')
            ?=([%apps %xchange %img %listing *] q.purl)
          ==
          =/  img-parts  +.+.+.+.q.purl  :: Get parts after /apps/xchange/img/listing/ (one more + since we're using full path now)
          =/  ad-id  -.img-parts
          =/  img-num  -.+.img-parts
          =/  purl-pair-simple  [ad-id img-num]
        [(serve-listing-image req purl-pair-simple now.bowl our.bowl eny listings1.state mylistings1.state) this]
      ?:  |(?=(~ +.q.purl) ?=([%xchange ~] +.q.purl) &(=(url.request.q.req '/apps/xchange') =(method.request.q.req %'GET')))
          =/  result  (xchange-main req our.bowl eny listings.state listings1.state my-avoids.state my-favorites.state sort-state.state)
          =/  cards  -.result
          =/  new-sort-state  +.result
          [cards this(sort-state.state new-sort-state)]
      ?:  ?=([%xchange %type *] +.q.purl)
          =/  result  (xchange-main req our.bowl eny listings.state listings1.state my-avoids.state my-favorites.state sort-state.state)
          =/  cards  -.result
          =/  new-sort-state  +.result
          [cards this(sort-state.state new-sort-state)]
      ?:  &(=(url.request.q.req '/apps/xchange/hide-listing') =(method.request.q.req %'POST'))
          =/  new-state  (hide-allad-state req now.bowl our.bowl eny mylistings.state mylistings1.state listings.state listings1.state)
          =/  cards  (hide-listing-webpage req our.bowl eny listings.state)
          [cards this(state new-state)]
      ?:  &(=(url.request.q.req '/apps/xchange/alert') =(method.request.q.req %'GET'))
        [(get-alert req our.bowl eny alerts.state listings1.state) this]
      ?:  &(=(url.request.q.req '/apps/xchange/alert') =(method.request.q.req %'POST'))
        =/  new-state  (post-alert-state req now.bowl our.bowl eny alerts.state alert-results.state listings.state listings1.state)
        =/  cards  (post-alert-webpage req our.bowl eny alerts.state)
        [cards this(state new-state)]
      ?:  &(=(url.request.q.req '/apps/xchange/delete-alert') =(method.request.q.req %'POST'))
        =/  new-state  (delete-alert-state req now.bowl our.bowl eny alerts.state alert-results.state)
        =/  cards  (delete-alert-webpage req our.bowl eny alerts.state)
        [cards this(state new-state)]
        ::deleting ad button
      ?:  &(=(url.request.q.req '/apps/xchange/delete-myad') =(method.request.q.req %'POST'))
          =/  new-state  (delete-myad-state req now.bowl our.bowl eny mylistings.state mylistings1.state listings.state listings1.state)
          =/  myad-id  (get-myad-id-from-request req)  :: Helper function to extract ID
          =/  web-cards  (delete-myad-webpage req our.bowl eny mylistings.state)
          =/  fact-card  [%give %fact ~[/ad-updates] %xchange-listings !>([%delete myad-id])]
          :_  this(state new-state)
          [fact-card web-cards]
      ?:  &(=(url.request.q.req '/apps/xchange/postad') =(method.request.q.req %'GET'))
        =/  cards
            (get-myad req our.bowl eny mylistings.state mylistings1.state message-myads.state sort-state.state)
        [cards this(state state(message-myads ''))]
        ::posting new add on post ad webpage
      ?:  &(=(url.request.q.req '/apps/xchange/postad') =(method.request.q.req %'POST'))
        =/  new-state  (post-myad-state req now.bowl our.bowl eny mylistings.state mylistings1.state listings.state listings1.state alerts.state alert-results.state message-myads.state maxpic-size.state)
        =/  myactive-listings  (get-active-listings mylistings1.new-state)
        =/  myinactive-listings  (get-inactive-listings mylistings1.new-state)
         ::~&  [%active-count ~(wyt by myactive-listings)]
         ::~&  [%inactive-count ~(wyt by myinactive-listings)]
        =/  web-cards  (post-myad-webpage req our.bowl eny mylistings1.state listings1.state)
        =/  fact-card  [%give %fact ~[/ad-updates] %xchange-listings !>([%ad-update myactive-listings])]
         :: Create delete cards for all inactive listings
        =/  delete-cards=(list card)
          %+  turn  ~(tap by myinactive-listings)
          |=  [id=@t advert=advert1]
          [%give %fact ~[/ad-updates] %xchange-listings !>([%delete id])]
        :_  this(state new-state)
        ::~&  [%delete-cards delete-cards]
            %+  weld  
              %+  weld  [fact-card ~] 
              delete-cards
            web-cards
          ::display manage my add webpage
      ?:  &(?=([%xchange %manage-myad *] +.q.purl) =(method.request.q.req %'GET'))
        [(get-manage-myad req purl-pair now.bowl our.bowl eny mylistings.state mylistings1.state) this]
      ?:  &(?=([%xchange %manage-alert *] +.q.purl) =(method.request.q.req %'GET'))
        [(get-manage-alert req purl-pair now.bowl our.bowl eny alerts.state alert-results.state listings1.state) this]
        ::
      ?:  &(?=([%xchange %view-alert *] +.q.purl) =(method.request.q.req %'GET'))
        [(get-view-alert req purl-pair now.bowl our.bowl eny alerts.state alert-results listings1.state) this]  
        :: update current ad
      ?:  &(?=([%xchange %manage-myad *] +.q.purl) =(method.request.q.req %'POST'))
        =/  new-state  (post-myad-state req now.bowl our.bowl eny mylistings.state mylistings1.state listings.state listings1.state alerts.state alert-results.state message-myads.state maxpic-size.state)
         =/  myactive-listings  (get-active-listings mylistings1.new-state)
        =/  myinactive-listings  (get-inactive-listings mylistings1.new-state)
         ::~&  [%active-count ~(wyt by myactive-listings)]
         ::~&  [%inactive-count ~(wyt by myinactive-listings)]
        =/  web-cards  (post-myad-webpage req our.bowl eny mylistings1.state listings1.state)
        =/  fact-card  [%give %fact ~[/ad-updates] %xchange-listings !>([%ad-update myactive-listings])]
         :: Create delete cards for all inactive listings
        =/  delete-cards=(list card)
          %+  turn  ~(tap by myinactive-listings)
          |=  [id=@t advert=advert1]
          [%give %fact ~[/ad-updates] %xchange-listings !>([%delete id])]
        :_  this(state new-state)
        ::~&  [%delete-cards delete-cards]
            %+  weld  
              %+  weld  [fact-card ~] 
              delete-cards
            web-cards
      ?:  &(?=([%xchange %manage-alert *] +.q.purl) =(method.request.q.req %'POST'))
          =/  new-state  (update-myalert-state req now.bowl our.bowl eny alerts.state listings.state listings1.state alert-results.state)
        =/  cards  (post-alert-webpage req our.bowl eny alerts.state)
        [cards this(state new-state)]
      ?:  &(?=([%xchange %view-ad *] +.q.purl) =(method.request.q.req %'GET'))
        [(get-view-ad req purl-pair now.bowl our.bowl eny mylistings.state mylistings1.state listings.state listings1.state) this]
      ::pals routing and rendering
      ?:  &(=(url.request.q.req '/apps/xchange/pals') =(method.request.q.req %'GET'))
        =/  cards
            (get-pals req our.bowl eny my-avoids.state my-favorites.state message-pals.state)
        [cards this(state state(message-pals ''))]
      :: pals favorites updates
      ?:  &(=(url.request.q.req '/apps/xchange/add-favorite') =(method.request.q.req %'POST'))
        =/  new-state=_state  (post-fav-state req now.bowl our.bowl eny my-favorites.state my-avoids.state message-pals.state)
        =/  cards  (post-pals-webpage req message-pals.state)
        [cards this(state new-state)]
      :: pals avoid update
      ?:  &(=(url.request.q.req '/apps/xchange/add-avoid') =(method.request.q.req %'POST'))
        =/  new-state=_state  (post-avoid-state req now.bowl our.bowl eny my-favorites.state my-avoids.state message-pals.state)
        =/  cards  (post-pals-webpage req message-pals)
        [cards this(state new-state)]
      ::
      ?:  &(=(url.request.q.req '/apps/xchange/delete-favorite') =(method.request.q.req %'POST'))
        =/  new-state=_state  (delete-favorite-state req my-favorites.state message-pals.state)
        =/  cards  (post-pals-webpage req message-pals.state)
      [cards this(state new-state)]
    ::
      ?:  &(=(url.request.q.req '/apps/xchange/edit-favorite') =(method.request.q.req %'POST'))
          =/  new-state=_state  (edit-favorite-state req my-favorites.state message-pals.state)
          =/  cards  (post-pals-webpage req message-pals.state)
          [cards this(state new-state)]
    ::
     ?:  &(=(url.request.q.req '/apps/xchange/delete-avoid') =(method.request.q.req %'POST'))
        =/  new-state=_state  (delete-avoid-state req my-avoids.state message-pals.state)
        =/  cards  (post-pals-webpage req message-pals.state)
        [cards this(state new-state)]
    ::
      ?:  &(=(url.request.q.req '/apps/xchange/edit-avoid') =(method.request.q.req %'POST'))
          =/  new-state=_state  (edit-avoid-state req my-avoids.state message-pals.state)
          =/  cards  (post-pals-webpage req message-pals.state)
          [cards this(state new-state)]
      ::  Sigil endpoint
      ?:  &(=(method.request.q.req %'GET') ?=([%xchange %sigil *] +.q.purl))
        [(serve-sigil req bowl eny) this]
        ::settings page
      ?:  &(=(url.request.q.req '/apps/xchange/settings') =(method.request.q.req %'GET'))
      [(get-settings req our.bowl maxpic-size.state maxad-timeout.state maxapp-size.state message-settings.state alerts.state alert-results.state mylistings1.state listings1.state) this(state state(message-settings ''))]
      ::settings state update
      ?:  &(=(url.request.q.req '/apps/xchange/settings') =(method.request.q.req %'POST'))
      =/  new-state  (update-settings-state req our.bowl maxpic-size.state maxad-timeout.state maxapp-size.state message-settings.state)
      ::  Clean the listings and alert-results using the updated settings
      =/  [cleaned-listings=_listings1.state cleaned-alert-results=_alert-results.state]
        (ad-manager now.bowl our.bowl listings1.state alert-results.state maxad-timeout.new-state maxapp-size.new-state)
      ::  Check memory and remove oldest ads if needed
      =/  final-listings  (remove-oldest-until-size our.bowl cleaned-listings cleaned-alert-results maxapp-size.new-state)
      =/  cards  (post-settings-webpage req our.bowl maxpic-size.state maxad-timeout.state maxapp-size.state)
      ::  Return cards and update state
      [cards this(state new-state(listings1 final-listings, alert-results cleaned-alert-results))]
      ::
      ?:  &(=(url.request.q.req '/apps/xchange/subscriptions') =(method.request.q.req %'GET'))
         [(get-subscriptions req our.bowl bowl alerts.state alert-results.state mylistings1.state listings1.state) this]
      ::
     ?:  &(?=([%xchange %search *] +.q.purl) =(method.request.q.req %'GET'))      
        [(get-search req -.+.purl our.bowl alerts.state listings1.state my-avoids.state my-favorites.state sort-state.state) this]
        
      ::default case if there is no matches
      =/  =response-header:http
          :-  404
            :~  ['Content-Type' 'text/html']
            ==
          :-  :~
                [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`'<html><body><h1>404 Not Found</h1></body></html>')]
                [%give %kick [/http-response/[p.req]]~ ~]
              ==
              this
        ==
    ::
    ++  on-watch
        |=  =path
        ^-  (quip card _this)
        ?+    path
          (on-watch:def path)
          [%http-response *]
          `this
          [%participants *]
              :: If this ship is the distribution ship, serve participant list
              ?:  =(our.bowl ~tabdyl)
          =/  new-xchange-ships  (~(put in xchange-ships) src.bowl)
          =/  participants  `distribution-action`[%participants new-xchange-ships]
          =/  add-participant  `distribution-action`[%add-participant src.bowl]
          =/  sub-to-new-ship  [%pass /ad-updates %agent [src.bowl %xchange] %watch /ad-updates]
          :_  this(xchange-ships new-xchange-ships)
          :~  [%give %fact ~ %xchange-distribution !>(participants)]      
              [%give %fact [/participants ~] %xchange-distribution !>(add-participant)]  
              sub-to-new-ship
          ==
        (on-watch:def path)
          [%ad-updates *]
                =/  myactive-listings
                  %-  malt
                  %+  turn
                    %+  skim
                      ~(tap by mylistings1)  :: Convert `map` to a `list`
                      |=  [key=@t value=advert1]
                      =(active.value %.y)  :: Keep only listings where `active=%.y`
                    |=  [key=@t value=advert1]
                    [key value]  :: Prepare key-value pairs for malt
                :_  this
                :~  [%give %fact ~ %xchange-listings !>([%ad-update myactive-listings])]
                ==
        ==

    ++  on-leave  on-leave:def
    ++  on-peek   on-peek:def
   ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ?+  wire  (on-agent:def wire sign)
       [%participants *] 
      ::~&  ['%xchange: [participants wire triggered, sign type:' -.sign 'from:' src.bowl]     
        ?+  -.sign  (on-agent:def wire sign)
          %fact
            =/  cage-sign  !<(distribution-action q.cage.sign)
            =/  distribution-ship  ~tabdyl
            =/  myactive-listings  (get-active-listings mylistings1.state)
                ?-  -.cage-sign
                  %participants
                    :: Got list of participants, subscribe to all of them.
                    ::~&  ['%xchange: received participants list with' ~(wyt in ships.cage-sign) 'ships']
                    =/  current-subs  
                      %-  ~(gas in *(set @p))
                      %+  turn  ~(tap by sup.bowl)
                      |=  [=duct [ship=@p =path]]
                      ?:  =(/ad-updates path)  ship
                      *@p
                    =/  new-ships  (~(dif in ships.cage-sign) current-subs)
                    ::~&  ['%xchange: subscribing to' ~(wyt in new-ships) 'new ships:' ~(tap in new-ships)]
                    =/  sub-cards=(list card)
                        %+  turn  
                          %+  skim  ~(tap in new-ships)
                          |=(ship=@p !=(ship our.bowl))
                        |=  ship=@p
                        [%pass /ad-updates %agent [ship %xchange] %watch /ad-updates]
                      :_  this(xchange-ships (~(uni in xchange-ships) ships.cage-sign))
                      ::~&  [%sub-cards sub-cards]
                      sub-cards
                  %add-participant
                    :: New participant added, subscribe to them and send them my active ads.
                    ?:  (~(has in xchange-ships) ship.cage-sign)
                      [~ this]  :: Already subscribed
                    :_  this(xchange-ships (~(put in xchange-ships) ship.cage-sign))
                    :~  [%pass /ad-updates %agent [ship.cage-sign %xchange] %watch /ad-updates]
                        [%give %fact ~[/ad-updates] %xchange-listings !>([%ad-update myactive-listings])]
                    ==            
                  %remove-participant
                    :: Participant removed, unsubscribe from them
                    ?:  !(~(has in xchange-ships) ship.cage-sign)
                      [~ this]  :: Not subscribed anyway
                    :_  this(xchange-ships (~(del in xchange-ships) ship.cage-sign))
                    :~  [%pass /ad-updates %agent [ship.cage-sign %xchange] %leave ~]
                    ==
                ==
          %kick
            :: Subscription was terminated, set a timer for 10 minutes to resubscribe
            =/  now  now.bowl
            =/  resub-time  (add now ~m10)  :: current time + 10 minutes
            :_  this
            :~  [%pass /xchange/resub-participants %arvo %b %wait resub-time]
            ==

        ==
        ::
        [%ad-updates *] 
        ::~&  ['%xchange: [ad-updates wire triggered, sign type:' -.sign 'from:' src.bowl]    
            ?+  -.sign  (on-agent:def wire sign)
              %fact
                =/  cage-sign  !<(action1 q.cage.sign)
                ?-  -.cage-sign
                  %ad-update
                    =/  [cleaned-listings=_listings1.state cleaned-alert-results=_alert-results.state]
                        (ad-manager now.bowl our.bowl listings1.state alert-results.state maxad-timeout.state maxapp-size.state)
                    =/  new-listings  (~(uni by cleaned-listings) listings1.cage-sign)
                    =/  new-alert-results  (alert-matches alerts new-listings)
                    ?:  (gth ~(wyt by new-alert-results) ~(wyt by alert-results))
                      :: CASE: we have more alert results now than before
                      =/  new-count  `@ud`(sub ~(wyt by new-alert-results) ~(wyt by alert-results))
                      =/  msg  (crip (weld "Xchange App: There are " (weld (scow %ud new-count) " new matche(s)!")))
                      =/  hark-card  (send-hark our.bowl msg now.bowl `@uvH`eny.bowl)
                      :_  this(listings1 new-listings, alert-results new-alert-results, alert-results cleaned-alert-results)
                      ~[hark-card]
                    :: CASE: no new alert results
                    [~ this(listings1 new-listings, alert-results new-alert-results)]
                  %delete
                  ::~&  [%delete-case-triggered id.cage-sign]  :: Add this
                  ::~&  [%id-exists-in-listings (~(has by listings1) id.cage-sign)]
                    =/  [cleaned-listings=_listings1.state cleaned-alert-results=_alert-results.state]
                        (ad-manager now.bowl our.bowl listings1.state alert-results.state maxad-timeout.state maxapp-size.state)
                    ::~&  [%cleaned-listings-count ~(wyt by cleaned-listings)]
                    ::~&  [%listings1-before-delete ~(wyt by listings1)]
                    =/  new-listings  (~(del by cleaned-listings) id.cage-sign)
                     ::~&  [%listings1-after-delete ~(wyt by new-listings)]
                    =/  new-alert-results  (alert-matches alerts new-listings)
                    [~ this(listings1 new-listings, alert-results new-alert-results, alert-results cleaned-alert-results)]
                ==
                %kick
                  =/  resub-time  (add now.bowl ~m10)
                  =/  kicked-ship  (scot %p src.bowl)
                  :_  this
                  :~  [%pass /xchange/resub-ad-updates/[kicked-ship] %arvo %b %wait resub-time]
                  ==
            ==
          ==
    ++  on-arvo
        |=  [=wire sign=sign-arvo]
        ^-  (quip card _this)
        ?+    wire  (on-arvo:def wire sign)
            [%bind-url ~]
          ?+    sign  (on-arvo:def wire sign)
              [%eyre %bound *]
              ::~&  [%eyre-bound binding.sign]
              `this
          ==
            [%xchange %timer ~]
            ::~&  [%timer-fired now.bowl]
            =/  [cleaned-listings=_listings1.state cleaned-alert-results=_alert-results.state]
                (ad-manager now.bowl our.bowl listings1.state alert-results.state maxad-timeout.state maxapp-size.state)
            =/  new-timer  (add now.bowl ~h1)
            ::~&  [%new-timer new-timer]
            :_  this(listings1 cleaned-listings, alert-results cleaned-alert-results)
            :~  [%pass /xchange/timer %arvo %b %wait new-timer]
            ==
            [%xchange %resub-participants ~]
              :: Resubscribe to the distribution ship (~tabdyl) after delay
              =/  distribution-ship  ~tabdyl
              ::~&  ['%xchange: timer fired, resubscribing to distribution ship' distribution-ship]
              :_  this
              :~  [%pass /participants %agent [distribution-ship %xchange] %watch /participants]
              ==
             [%xchange %resub-ad-updates @ ~]
              :: Timer fired — resubscribe to the kicked ship
              =/  kicked-ship=@p  (slav %p i.t.t.wire)
              ::~&  ['%xchange: resub timer fired for' kicked-ship]
              :_  this
              :~  [%pass /ad-updates %agent [kicked-ship %xchange] %watch /ad-updates]
              ==
        ==

    ++  on-fail   on-fail:def
  --
  |_  bol=bowl:gall
    ++  gilt                                                 ::  page helpers
      |%
      ++  eth-key
        |=  [k=@t]
        ^-  (quip card _state)
        :_  state(etherscankey k)
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'etherscan-key'
            key+s+k
            status+s+'Etherscan Credentials Updated'
        ==
        ::
      ++  add-myad
        |=  [a=@t ad=advert]
        :_  state(mylistings (~(put by mylistings) a ad))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'new ad from me'
            status+s+'New Ad from my ship'
        ==
        ++  del-myad
        |=  [a=@t ad=advert]
        :_  state(mylistings (~(del by mylistings) a))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'del ad from me'
            status+s+'del Ad from my ship'
        ==
        ++  add-allad
        |=  [a=@t ad=advert]
        :_  state(listings (~(put by listings) a ad))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'new ad from network'
            status+s+'New Ad from network'
        ==
         ++  del-allad
        |=  [a=@t ad=advert]
        :_  state(listings (~(del by listings) a))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'del ad from network'
            status+s+'del Ad from network'
        ==
        ++  add-alert
        |=  [a=@t alertinfo=alert]
        :_  state(alerts (~(put by alerts) a alertinfo))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'new alert'
            status+s+'New alert'
        ==
        ++  del-alert
        |=  [a=@t alertinfo=alert]
        :_  state(alerts (~(del by alerts) a))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'del alert'
            status+s+'del alert'
        ==
        ::
        ++  add-favorite
        |=  [a=@p comment=@t]
        :_  state(my-favorites (~(put by my-favorites) a comment))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'new favorite'
            status+s+'New favorite'
        ==
        ::
         ++  del-favorite
        |=  [a=@p comment=@t]
        :_  state(my-favorites (~(del by my-favorites) a))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'del favorite'
            status+s+'del favorite'
        ==
        ::
        ++  add-avoid
        |=  [a=@p b=my-avoid]
        :_  state(my-avoids (~(put by my-avoids) a b))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'new avoid'
            status+s+'New avoid'
        ==
        ::
         ++  del-avoid
        |=  [a=@p b=my-avoid]
        :_  state(my-avoids (~(del by my-avoids) a))
        =-  [%give %fact ~[/website] json+!>(`json`-)]~
        %-  pairs:enjs:format
        :~  head+s+'del avoid'
            status+s+'del avoid'
        ==
      --
    ::
    ++  subscribe-to-ship
          |=  =ship
          ^-  (quip card _state)
          :_  state
          :~  [%pass /ad-updates/(scot %p ship) %agent [ship %xchange] %watch /ad-updates]
          ==
     ++  unsubscribe-to-ship
          |=  =ship
          ^-  (quip card _state)
          :_  state
          :~  [%pass /ad-updates-wire/(scot %p ship) %agent [ship %xchange] %leave ~]
          ==
    ++  http-login-redirect
      |=  req=(pair @ta inbound-request:eyre)
      ^-  (list card)
        =/  =response-header:http
          :-  301
          :~  ['Location' '/~/login?redirect=/apps/xchange']
          ==
        :~
          [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
          [%give %fact [/http-response/[p.req]]~ %http-response-data !>(~)]
          [%give %kick [/http-response/[p.req]]~ ~]
        ==
        ::
        ::This ++invalid-http-request-method function generates an HTTP response for a 405 Method Not Allowed error. 
        ::It provides the necessary HTTP headers, an HTML error body, and a signal to finalize the response.
    ++  invalid-http-request-method
      |=  req=(pair @ta inbound-request:eyre)
      ^-  (list card)
        =/  data=octs
          (as-octs:mimes:html '<h1>405 Method Not Allowed</h1>')
        =/  content-length=@t
          (crip ((d-co:co 1) p.data))
        =/  =response-header:http
          :-  405
          :~  ['Content-Length' content-length]
              ['Content-Type' 'text/html']
              ['Allow' 'GET']
          ==
        :~
          [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
          [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`data)]
          [%give %kick [/http-response/[p.req]]~ ~]
        ==
        ::This ++invalid-ship-redirect function generates an HTTP redirect response for invalid ship input. 
        ::It returns a 301 Moved Permanently status code and redirects the client to the /apps/file-share/invalid-input path.
        ::
    ++  invalid-ship-redirect
      |=  req=(pair @ta inbound-request:eyre)
      ^-  (list card)
      =/  =response-header:http
        :-  301
        :~  ['Location' '/apps/file-share/invalid-input']
        ==
      :~
        [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
        [%give %fact [/http-response/[p.req]]~ %http-response-data !>(~)]
        [%give %kick [/http-response/[p.req]]~ ~]
      ==
      ::The ++page-not-found-response function is designed to generate an HTTP response for a "404 Not Found" error. It prepares the necessary response headers and sends the response to the client.
      ::
      ++  page-not-found-response
      |=  req=(pair @ta inbound-request:eyre)
      ^-  (list card)
        =/  =response-header:http
        :-  404
        :~  ['Content-Type' 'text/html']
        ==
      :~
        [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
        [%give %fact [/http-response/[p.req]]~ %http-response-data !>(~)]
        [%give %kick [/http-response/[p.req]]~ ~]
      ==
      ::This ++favicon function provides a simple SVG-based favicon for a web application. 
      ::A favicon is a small icon associated with a website, often displayed in browser tabs, bookmarks, or address bars.
    ++  favicon
      ^-  tape
      %-  trip
      '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 99.8 122.88"><defs><style>.cls-1{fill-rule:evenodd;}</style></defs><title>compare file</title><path class="cls-1" d="M67.47,118.48a4.4,4.4,0,0,1-4.38,4.4H4.4a4.38,4.38,0,0,1-3.11-1.29A4.35,4.35,0,0,1,0,118.48V41.69a4.4,4.4,0,0,1,4.4-4.4H29V25.55a2.57,2.57,0,0,1,1.87-2.48L53.55,1a2.52,2.52,0,0,1,2-.95H95.18A4.63,4.63,0,0,1,99.8,4.62V85.23a4.63,4.63,0,0,1-4.62,4.62H67.48v28.63ZM34.11,37.29h8.06a2.4,2.4,0,0,1,1.88.9L65.7,59.27a2.44,2.44,0,0,1,1.78,2.36V84.69H94.64V53.82H87.08v5.84c-.11,2.52-2,3.45-4.28,2.67a1.24,1.24,0,0,1-.36-.19C76.62,57.57,72.6,53,66.77,48.42l-.08-.07c-1.77-1.62-1.25-3.46.47-4.81L81.45,30.86a6.91,6.91,0,0,1,2.11-1.18,2.45,2.45,0,0,1,3.17,1.38,5.05,5.05,0,0,1,.35,2c0,1.81,0,3.64,0,5.45h7.56V5.13H58.12V26.05a2.59,2.59,0,0,1-2.59,2.59H34.11v8.65ZM53,9,37.53,23.48H53V9Zm-40.84,65H4.91V42.18H39.7V62.1a2.47,2.47,0,0,0,2.47,2.47h20.4q0,26.7,0,53.4H4.91V88.64h7.21V94.2c.1,2.4,1.88,3.28,4.07,2.54a1,1,0,0,0,.34-.18c5.55-4.36,9.38-8.71,14.93-13.07l.07-.07c1.7-1.53,1.19-3.29-.44-4.58L17.48,66.77a6.43,6.43,0,0,0-2-1.13,2.34,2.34,0,0,0-3,1.32,4.78,4.78,0,0,0-.32,1.9c0,1.73,0,3.47,0,5.19ZM44.61,45.89l14.7,13.77H44.61V45.89Z"/></svg>'
    ::
     ++  xchange-main
      |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t listings=(map id=@t advert) listings1=(map id=@t advert1) my-avoids=(map ship=@p my-avoid) my-favorites=(map ship=@p comment=@t) sort-state=[column=@t ascending=?]]
      ^-  [(list card) [column=@t ascending=?]]
      =/  purl  (rash url.request.q.req ;~(plug apat:de-purl:html yque:de-purl:html))
        =/  path  q.purl
        =/  filter-type
          ?:  ?=(^ path)
            ?:  ?=(^ t.path)
              ?:  ?=(^ t.t.path)
                ?:  &(=(i.path %apps) =(i.t.path %xchange) =(i.t.t.path %type))
                  ?:  ?=(^ t.t.t.path)
                    i.t.t.t.path
                  'all'
                'all'
              'all'
            'all'
          'all'
      =/  active-listings  %+  skim  ~(tap by listings1.state)
          |=  a=[id=@t [ad-title=@t when=@da type=@t price=(unit @t) timezone=(unit @t) contact=@t ship=@p body=@t active=? image1=(unit image-info1) image2=(unit image-info2)]]
          =/  should-block
          ?~  avoid-entry=(~(get by my-avoids.state) ship.a)
            %.n
          block.u.avoid-entry
          ?:  should-block
            %.n
          ?:  =(filter-type 'all')
            =(%.y active.a)
          &(=(%.y active.a) =(type.a filter-type))
      ::  Handle sorting from POST request
      =/  updated-sort-state  (handle-sort req sort-state)
      ::~&  [%debug-sort-state column.updated-sort-state ascending.updated-sort-state]
      ::  Apply sorting to active listings
      =/  sorted-listings  (sort-listings active-listings column.updated-sort-state ascending.updated-sort-state)
      =/  body
        %-  as-octs:mimes:html
        %-  crip
        %-  en-xml:html
        ;html
              ;head
                ;title:"Xchange"
                ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                ;meta(charset "utf-8");
                ;meta(name "viewport", content "width=device-width, initial-scale=1");
                ;style: {style}
              ==  :: closes `;head`
            ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                     ;div.menu-bar
                    ;ul
                      ;li
                        ;a(href "/apps/xchange"): All
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/services"): Services
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/events"): Events
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/jobs"): Jobs
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/for_sale"): For-Sale
                      ==
                    ==
                  ==::closes menu-bar
                  ;div.main-content
                   ;div.left-bar
                    ;ul
                         ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                         ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==                       
                        ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                        ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                  ;div.table-wrapper
                  ;+  ?:  =(sorted-listings ~)
                      ;div.table-main
                        ;table
                            ;tr
                                ;th: Thumbnail
                                ;th: Title
                                ;th: Date Posted
                                ;th: Type
                                ;th: Price
                                ;th: Timezone
                                ;th: Contact Information
                                ;th: ship
                                ;th: Description
                                ;th: active
                            ==               :: closes `;tr`
                            ;tr
                              ;td#empty-row(colspan "10")
                                  ;p: No ads recieved yet.
                              ==    ::closes ;td
                            ==        ::closes ;tr
                        ==                 :: closes `;table`
                      ==                   :: closes `;div#table-all`           
                  ;div.table-div
                        ;table(style "width: 90%")
                          ;tr
                            ;th(style "width: 220px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "thumbnail");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline;"): Thumbnail
                              ==
                            ==
                            ;th(style "width: 150px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "title");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline;"): Title {?:(=(column.updated-sort-state 'title') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 100px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "date");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline;"): Date Posted {?:(=(column.updated-sort-state 'date') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 80px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "type");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline; text-align: center;"): Type {?:(=(column.updated-sort-state 'type') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 80px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "price");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline; text-align: center;"): Price {?:(=(column.updated-sort-state 'price') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 100px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "timezone");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline; text-align: center;"): Timezone {?:(=(column.updated-sort-state 'timezone') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 120px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "contact");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline; text-align: center;"): Contact Information {?:(=(column.updated-sort-state 'contact') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 120px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "ship");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline; text-align: center;"): ship {?:(=(column.updated-sort-state 'ship') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 200px; text-align: center;")
                              ;form(method "post", style "display: inline;")
                                ;input(type "hidden", name "column", value "body");
                                ;button(type "submit", style "background: none; border: none; cursor: pointer; font-size: 24px; text-decoration: underline; text-align: center;"): Description {?:(=(column.updated-sort-state 'body') ?:(ascending.updated-sort-state "↑" "↓") "")}
                              ==
                            ==
                            ;th(style "width: 80px; text-align: center;"): Actions
                          ==               :: closes `;tr`
                          ;*  %+  turn  sorted-listings
                            |=  a=[id=@t [ad-title=@t when=@da type=@t price=(unit @t) timezone=(unit @t) contact=@t ship=@p body=@t active=? image1=(unit image-info1) image2=(unit image-info2)]]
                              ;tr
                                ;td(style "display: none;"): {(trip id.a)}
                                  ;td(style "text-align: center; vertical-align: middle; word-wrap: break-word; overflow-wrap: break-word;")
                                      ;+  ?~  image1.a
                                        ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                                      ?:  =(filename1.u.image1.a '')
                                        ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                                        ;img(src "/apps/xchange/img/listing/{(trip id.a)}/1", alt "Thumbnail", style "max-width: 200px; max-height: 200px; object-fit: cover; border-radius: 4px;");
                                ==:: closes td
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 150px;")
                                  ;a(href "/apps/xchange/view-ad?ad-id={(trip id.a)}"): {(trip ad-title.a)}
                                  ==
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word;"): {(trip (get-date when.a))}
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word;"): {(trip type.a)}
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word;"): {?:((gth (lent (trip +.price.a)) 60) (weld (scag 60 (trip +.price.a)) "...") (trip +.price.a))}
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word;"): {?:((gth (lent (trip +.timezone.a)) 60) (weld (scag 60 (trip +.timezone.a)) "...") (trip +.timezone.a))}
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 120px; white-space: normal;"): {?:((gth (lent (trip contact.a)) 60) (weld (scag 60 (trip contact.a)) "...") (trip contact.a))}
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 120px;")
                                    ;+  ?:  (~(has by my-favorites.state) ship.a)
                                          ;div
                                            ;span(style "color: green; font-size: 32px;"): ♥
                                            ;span: {(trip (scot %p ship.a))}
                                          ==
                                        ?:  (~(has by my-avoids.state) ship.a)
                                          ;div
                                            ;span(style "color: black; font-size: 32px;"): ❌
                                            ;span: {(trip (scot %p ship.a))}
                                          ==
                                        ;span: {(trip (scot %p ship.a))}
                                    ==
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 200px; white-space: normal;"): {?:((gth (lent (trip body.a)) 60) (weld (scag 60 (trip body.a)) "...") (trip body.a))}
                                ;td(style "display: none;"): {(trip active.a)}
                                ;td(style "word-wrap: break-word; overflow-wrap: break-word;")
                                  ;form(method "post", action "/apps/xchange/hide-listing")
                                    ;input(type "hidden", name "listing-id", value "{(trip id.a)}");
                                    ;button(type "submit", class "hide-button", onclick "return confirm('Are you sure you want to hide this ad?');"): Hide
                                  ==::closes form
                              == :: closes tr
                            ==
                          ==     :: closes `;table`
                      ==  ::closes .table-div
                    ==::closes table-wrapper 
                ==::closes main-content 
              ==
            ==
            =/  =response-header:http
                :-  200
                :~  ['content-type' 'text/html; charset=utf-8']
                ==
              =/  cards
              :~
                [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                [%give %kick [/http-response/[p.req]]~ ~]
              ==
               [cards updated-sort-state]
    ::
            ::
            ++  hide-allad-state
              |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t mylistings=(map id=@t advert) mylistings1=(map id=@t advert1) listings=(map id=@t advert) listings1=(map id=@t advert1)]
              ^+  state
              =/  data=octs  +.body.request.q.req
              =/  text-data  (crip (trip +.data))
              =/  parsedata  (need (rush text-data yquy:de-purl:html))
              =/  listing-id  (snag 0 parsedata)
              =/  current-listing  (~(got by listings1.state) +.listing-id)
              =/  updated-listing  current-listing(active %.n)
              =/  updated-listings  (~(put by listings1.state) +.listing-id updated-listing)
              =/  updated-mylistings  ?:  (~(has by mylistings1.state) +.listing-id)
                                          (~(put by mylistings1.state) +.listing-id updated-listing)
                                          mylistings1.state
              state(mylistings1 updated-mylistings, listings1 updated-listings)
            ::
            ++  hide-listing-webpage
              |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t listings=(map id=@t advert)]
              ^-  (list card)
              =/  =response-header:http
                :-  303
                :~  ['location' '/apps/xchange']
                ==
              :~
                [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                [%give %kick [/http-response/[p.req]]~ ~]
              ==
            ++  get-alert
              |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t alerts=(map alert-id=@t alert) listings1=(map id=@t advert1)]
              ^-  (list card)
              =/  body
                %-  as-octs:mimes:html
                %-  crip
                %-  en-xml:html
                ;html
                    ;head
                      ;title:"Xchange"
                      ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                      ;meta(charset "utf-8");
                      ;meta(name "viewport", content "width=device-width, initial-scale=1");
                      ;style: {style}
                    ==::closes head
                      ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                ::
                ;div.main-content
                   ;div.left-bar
                    ;ul
                        ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                        ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==
                        ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                          ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                    ;div.alert-wrapper
                        ;div.table-div-alerts
                        ;form(method "post", action "/apps/xchange/alert")
                            ;table.alerts-form-table
                                ;tr
                                  ;div.myad-input-cell 
                                  ;th(colspan "2", style "text-align: center;"): Enter New Alert
                                  ==
                                ==  :: Closes title row
                                ;tr
                                  ;td: Search Title
                                  ;td
                                      ;div.alert-input-cell
                                        ;input(type "text", name "searchtitle", placeholder "Enter Title Search", style "font-size: 18px;");
                                      ==
                                    ==
                                  ==
                                ;tr
                                  ;td: Title
                                    ;td
                                      ;div.alert-input-cell
                                        ;input(type "text", name "keywordtitle", placeholder "Enter Keyword Searches in Title", style "font-size: 18px;");
                                      ==
                                    ==
                                  ==
                                ;tr
                                  ;td: Type
                                    ;td
                                    ;div.alert-input-cell
                                      ;select(name "type", class "dropdown", style "font-size: 18px;")
                                        ;option(value "services"): Services
                                        ;option(value "events"): Events
                                        ;option(value "jobs"): Jobs
                                        ;option(value "for_sale"): For Sale
                                      ==
                                    ==
                                  ==
                                ;tr
                                  ;td: Price
                                  ;td
                                      ;div.alert-input-cell
                                        ;input(type "text", name "alertprice", placeholder "Enter Search Price", style "font-size: 18px;");
                                      ==
                                    ==
                                  ==
                                ;tr
                                  ;td: Timezone
                                    ;td
                                      ;div.alert-input-cell
                                        ;input(type "text", name "alerttimezone", placeholder "Enter Timezone Alert", style "font-size: 18px;");
                                      ==
                                    ==
                                ==
                                ;tr
                                  ;td: Contact Information
                                    ;td
                                      ;div.alert-input-cell
                                      ;input(type "text", name "alertcontact", placeholder "Enter Contact Alert", style "font-size: 18px;");
                                    ==
                                  ==
                                ==
                                ;tr
                                ;td: Ship Information
                                    ;td
                                      ;div.alert-input-cell
                                      ;input(type "text", name "alertship", placeholder "Enter Ship Alert", style "font-size: 18px;");
                                    ==
                                  ==
                                ==
                                ;tr
                                ;td: Description
                                ;td
                                  ;div.alert-input-cell
                                    ;textarea(name "description", placeholder "Enter item details", rows "5", style "font-size: 18px; width: 100%; resize: vertical; overflow: auto;");
                                      ==
                                    ==
                                ==
                                ;tr
                                    ;td: Active
                                    ;td
                                      ;div.alert-input-cell
                                      ;select(name "alert status", class "dropdown", style "font-size: 18px;")
                                      ;option(value "%.y"): Yes
                                      ;option(value "%.n"): No
                                      ==
                                    ==
                                  ==
                                ==
                                ;tr
                                  ;td(colspan "2", style "text-align: center;")
                                    ;button(type "submit", class "submit-button"): Setup an alert
                                  ==
                                ==
                            ==  :: Closes table
                        ==  ::closes form
                      ==  :: Closes div.table-div-alerts
                    == 
                    ;+  ?:  =(alerts.state ~)
                        ;div.table-div
                              ;table
                                ;tr
                                  ;th(colspan "9", style "text-align: center;"): My Current Alerts
                                ==  :: Closes title row
                                ;tr
                                  ;th: Alert-Title
                                  ;th: Ad-Title Alert
                                  ;th: Alert Date
                                  ;th: Type Alert
                                  ;th: Price Alert
                                  ;th: Timezone Alert
                                  ;th: Contact Alert
                                  ;th: Ship Alert
                                  ;th: Description Alert
                                  ;th: Search Active
                                ==:: closes tr
                                ;tr
                                  ;td#empty-row(colspan "9")
                                      ;p: No Alerts
                                  ==
                                ==
                              ==
                          ==
                      ::
                      ::
                      =/  alertslist  ~(tap by alerts.state)
                        ;div.table-div
                            ;table
                              ;tr
                                  ;th(colspan "9", style "text-align: center;"): My Current Alerts
                                ==  :: Closes title row
                              ;tr
                                  ;th: Alert-Title
                                  ;th: Ad-Title Alert
                                  ;th: Alert Date
                                  ;th: Type Alert
                                  ;th: Price Alert
                                  ;th: Timezone Alert
                                  ;th: Contact Alert
                                  ;th: Ship Alert
                                  ;th: Description Alert
                                  ;th: Search Active
                                ;th; 
                              ==:: closes tr
                              ;*  %+  turn  alertslist
                                |=  a=[id=@t [alert-title=@t ad-title=@t when=@da type=@t price=(unit @t) timezone=(unit @t) contact=@t ship=@t body=@t active=?]]
                                  ;tr
                                    ;td(style "display: none;"): {(trip id.a)}
                                    ;td: {(trip alert-title.a)}
                                    ;td: {(trip ad-title.a)}
                                    ;td: {(trip (get-date when.a))}
                                    ;td: {(trip type.a)}
                                    ;td: {(trip +.price.a)}
                                    ;td: {(trip +.timezone.a)}
                                    ;td: {(trip contact.a)}
                                    ;td: {(trip ship.a)}
                                    ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 200px; white-space: normal;"): {?:((gth (lent (trip body.a)) 60) (weld (scag 60 (trip body.a)) "...") (trip body.a))}
                                    ;td: {(trip (scot %f active.a))}
                                    ;td
                                        ;form(method "post", action "/apps/xchange/delete-alert")
                                          ;input(type "hidden", name "alert-id", value "{(trip id.a)}");
                                          ;button(type "submit", class "delete-button", onclick "return confirm('Are you sure you want to delete this alert?');"): Delete
                                        == ::closes delete form
                                        ;form(method "get", action "/apps/xchange/manage-alert")
                                          ;input(type "hidden", name "alert-id", value "{(trip id.a)}");
                                          ;button(type "submit", class "manage-button"): Manage
                                        == ::closes manage form
                                        ;form(method "get", action "/apps/xchange/view-alert")
                                          ;input(type "hidden", name "alert-id", value "{(trip id.a)}");
                                          ;button(type "submit", class "view-button"): View
                                        == ::closes manage form
                                      ==
                                    ==
                                  ==
                                ==  
                            ==::closes table
                        ==::closes div.table-div    
                  ==::closes body
              ==:: closes html
                =/  =response-header:http
                    :-  200
                    :~  ['content-type' 'text/html; charset=utf-8']
                    ==
                  :~
                    [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                    [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                    [%give %kick [/http-response/[p.req]]~ ~]
                  ==
            ::
            ++  post-alert-webpage
              |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t alerts=(map alert-id=@t alert)]
              ^-  (list card)
              =/  =response-header:http
                  :-  301
                  :~  ['Location' '/apps/xchange/alert']
                  ==
                :~
                  [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                  [%give %kick [/http-response/[p.req]]~ ~]
                ==
            ::
            ++  post-alert-state
                |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t alerts=(map alert-id=@t alert) alert-results=(map ad-id=@t alert-result) listings=(map id=@t advert) listings1=(map id=@t advert1)]
                =/  data=octs  +.body.request.q.req
                =/  text-data  (crip (trip +.data))
                =/  parsedata  (need (rush text-data yquy:de-purl:html))
                =/  new-alert-title  (snag 0 parsedata)
                =/  new-alert-adtitle  (snag 1 parsedata)
                =/  new-alert-type  (snag 2 parsedata)
                =/  new-alert-price  (snag 3 parsedata)
                =/  new-alert-timezone  (snag 4 parsedata)
                =/  new-alert-contact  (snag 5 parsedata)
                =/  new-alert-ship  (snag 6 parsedata)
                =/  new-alert-description  (snag 7 parsedata)
                =/  raw-status  (snag 8 parsedata)  :: parse logical as a cord 
                =/  new-alert-status  ?:  =(+.raw-status '%.y')  %.y  %.n  :: Compare & convert to @f
                =/  newpair  [eny [+.new-alert-title +.new-alert-adtitle now +.new-alert-type [~ +.new-alert-price] [~ +.new-alert-timezone] +.new-alert-contact +.new-alert-ship +.new-alert-description new-alert-status]]
                =/  newalerts  (~(put by alerts) newpair)
                =/  new-alert-results  (alert-matches newalerts listings1)
                state(alerts newalerts, alert-results new-alert-results)
            ++  get-myad
              |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t mylistings=(map id=@t advert) mylistings1=(map id=@t advert1) message-myads=@t sort-state=[column=@t ascending=?]]
              ^-  (list card)
              =/  listmylistings  ~(tap by mylistings1.state)
              ::  Handle sorting from POST request
              =/  updated-sort-state  (handle-sort req sort-state)
              ::~&  [%debug-sort-state column.updated-sort-state ascending.updated-sort-state]
              ::  Apply sorting to active listings
              =/  sorted-listings  (sort-listings listmylistings column.updated-sort-state ascending.updated-sort-state)
              =/  body
                %-  as-octs:mimes:html
                %-  crip
                %-  en-xml:html
                ;html
                    ;head
                      ;title:"Xchange"
                      ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                      ;meta(charset "utf-8");
                      ;meta(name "viewport", content "width=device-width, initial-scale=1");
                      ;style: {style}
                       ;script
                        ; document.addEventListener('DOMContentLoaded', function() {{
                        ;   const maxSize = 2 * 1024 * 1024;
                        ;   const fileInputs = document.querySelectorAll('.file-input');
                        ;   
                        ;   fileInputs.forEach(function(input) {{
                        ;     input.addEventListener('change', function(e) {{
                        ;       const file = e.target.files[0];
                        ;       if (file && file.size > maxSize) {{
                        ;         alert('File ' + file.name + ' is too large. Maximum size is 2MB. Selected file is ' + 
                        ;               (file.size / 1024 / 1024).toFixed(2) + 'MB');
                        ;         e.target.value = '';
                        ;       }}
                        ;     }});
                        ;   }});
                        ;   
                        ;   document.querySelector('form[action="/apps/xchange/postad"]').addEventListener('submit', function(e) {{
                        ;     for (let input of fileInputs) {{
                        ;       const file = input.files[0];
                        ;       if (file && file.size > maxSize) {{
                        ;         e.preventDefault();
                        ;         alert('Please remove files larger than 2MB before submitting');
                        ;         return false;
                        ;       }}
                        ;     }}
                        ;   }});
                        ; }});
                      ==
                    ==::closes head
                      ;body
             ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                ::
                ;div.main-content
                   ;div.left-bar
                    ;ul
                        ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                        ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==
                        ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                         ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                ::
                    ;+  ?:  =(message-myads '')
                    ;div;
                  ::
                  =/  search-result  (find "Successfully" (trip message-myads))
                  =/  contains-success  ?=(^ search-result)
                  =/  bg-color  ?:(contains-success "#d4edda" "#f8d7da")
                  =/  border-color  ?:(contains-success "#c3e6cb" "#f5c6cb")
                  =/  text-color  ?:(contains-success "#155724" "#721c24")
                  ;div(style "display: flex; justify-content: center; margin: 20px 0;")
                    ;div(style "width: 75%; height: 300px; padding: 15px; text-align: center; background: {bg-color}; border: 1px solid {border-color}; border-radius: 4px; color: {text-color}; font-size: 18px;")
                      ;p: {(trip message-myads)}
                    ==
                  ==
                  ;div.alert-wrapper
                      ;div.table-div-ads
                    ;form(method "post", action "/apps/xchange/postad", enctype "multipart/form-data", onsubmit "this.style.cursor='wait'; this.querySelector('.submit-button').disabled=true; this.querySelector('.submit-button').textContent='Adding Ad...'; document.body.style.cursor='wait';")
                      ;table.myad-form-table
                        ;tr
                          ;div.myad-input-cell 
                            ;th(colspan "2", style "text-align: center;"): Enter New Post
                          ==
                        ==
                        ;tr
                          ;td: Title
                          ;td
                            ;div.myad-input-cell
                              ;input(type "text", name "title", placeholder "Enter Listing Title", style "font-size: 18px;");
                            ==
                          ==
                        ==
                        ;tr
                          ;td: Type
                          ;td
                            ;div.dropdown
                              ;select(name "type", class "dropdown", style "font-size: 18px;")
                                ;option(value "services"): Services
                                ;option(value "events"): Events
                                ;option(value "jobs"): Jobs
                                ;option(value "for_sale"): For Sale
                              ==
                            ==
                          ==
                        ==
                        ;tr
                          ;td: Price
                          ;td
                            ;div.myad-input-cell
                              ;input(type "text", name "price", placeholder "Enter Item Price", style "font-size: 18px;");
                            ==
                          ==
                        ==
                        ;tr
                          ;td: Timezone
                          ;td
                            ;div.myad-input-cell
                              ;input(type "text", name "timezone", placeholder "Enter Contact Timezone", style "font-size: 18px;");
                            ==
                          ==
                        ==
                        ;tr
                          ;td: Contact Information
                          ;td
                            ;div.myad-input-cell
                              ;input(type "text", name "contact", placeholder "Enter contact details", style "font-size: 18px;");
                            ==
                          ==
                        ==
                        ;tr
                          ;td: Description
                          ;td
                            ;div.myad-input-cell3lines
                              ;textarea(name "description", placeholder "Enter item details", rows "5", style "font-size: 18px; width: 100%; resize: vertical; overflow: auto;");
                            ==
                          ==
                        ==
                        ;tr
                          ;td: Active
                          ;td
                            ;div.dropdown
                              ;select(name "active", class "dropdown", style "font-size: 18px;")
                                ;option(value "%.y"): Yes
                                ;option(value "%.n"): No
                              ==
                            ==
                          ==
                        ==
                        ;tr
                          ;td: Post Images
                          ;td
                            ;div(style "display: flex; gap: 12px")
                              ;input(type "file", name "image1", class "file-input");
                              ;input(type "file", name "image2", class "file-input");
                            ==
                          ==
                        ==
                        ;tr
                          ;td(colspan "2", style "text-align: center;")
                            ;button(type "submit", class "submit-button"): post an ad
                          ==
                        ==
                      ==  :: Closes table
                    ==  :: Closes form
                  ==  :: Closes div.table-div-ads
                    ;+  ?:  =(mylistings1.state ~)
                        ;div.table-div
                              ;table
                                ;tr
                                ;th: Thumbnail
                                ;th: Title
                                ;th: Date Posted
                                ;th: Type
                                ;th: Price
                                ;th: Timezone
                                ;th: Contact Information
                                ;th: ship
                                ;th: Description
                                ;th: active
                                ==:: closes tr
                                ;tr
                                  ;td#empty-row(colspan "10")
                                      ;p: No Ads
                                  ==
                                ==
                              ==
                          ==
                      =/  mylistingslist  ~(tap by mylistings1.state)
                        ;div.table-div
                            ;table
                              ;tr
                                ;th: Thumbnail
                                ;th: Title
                                ;th: Date Posted
                                ;th: Type
                                ;th: Price
                                ;th: Timezone
                                ;th: Contact Information
                                ;th: Ship
                                ;th: Description
                                ;th: Active
                                ;th;  
                              ==:: closes tr
                              ;*  %+  turn  mylistingslist
                                      |=  a=[id=@t ad-title=@t when=@da type=@t price=(unit @t) timezone=(unit @t) contact=@t ship=@p body=@t active=? image1=(unit image-info1) image2=(unit image-info2)]
                                        ;tr
                                          ;td(style "display: none;"): {(trip id.a)}
                                          ;td(style "text-align: center; vertical-align: middle;")
                                              ;+  ?~  image1.a
                                                ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                                              ?:  =(filename1.u.image1.a '')
                                                ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                                                ;img(src "/apps/xchange/img/listing/{(trip id.a)}/1", alt "Thumbnail", style "max-width: 80px; max-height: 80px; object-fit: cover; border-radius: 4px;");
                                              ==
                                                  ::;td(style "font-family: monospace; font-size: 10px; background-color: yellow; word-break: break-all; white-space: normal; max-width: 100px; overflow-wrap: break-word;"): {(trip id.a)}
                                          ;td
                                            ;a(href "/apps/xchange/view-ad?ad-id={(trip id.a)}"): {(trip ad-title.a)}
                                            ==
                                          ;td: {(trip (get-date when.a))}
                                          ;td: {(trip type.a)}
                                          ;td: {?:((gth (lent (trip +.price.a)) 60) (weld (scag 60 (trip +.price.a)) "...") (trip +.price.a))}
                                          ;td: {?:((gth (lent (trip +.timezone.a)) 60) (weld (scag 60 (trip +.timezone.a)) "...") (trip +.timezone.a))}
                                          ;td: {?:((gth (lent (trip contact.a)) 60) (weld (scag 60 (trip contact.a)) "...") (trip contact.a))}
                                          ;td: {(trip (scot %p ship.a))}
                                          ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 200px; white-space: normal;"): {?:((gth (lent (trip body.a)) 60) (weld (scag 60 (trip body.a)) "...") (trip body.a))}
                                          ;td: {(trip (scot %f active.a))}
                                          ;td
                                              ;form(method "post", action "/apps/xchange/delete-myad")
                                                ;input(type "hidden", name "myad-id", value "{(trip id.a)}");
                                                ;button(type "submit", class "delete-button", onclick "return confirm('Are you sure you want to delete this ad?');"): Delete
                                              == ::closes delete form
                                              ;form(method "get", action "/apps/xchange/manage-myad")
                                                ;input(type "hidden", name "myad-id", value "{(trip id.a)}");
                                                ;button(type "submit", class "manage-button"): Manage
                                              == ::closes manage form
                                              ::;button(type "button", onclick "prompt('Ad ID (select and copy):', '{(trip id.a)}')", class "id-button"): View ID
                                          == :: closes td
                                        ==     :: closes tr
                            ==::closes table
                        ==::closes div.table-div 
                      ==
                    ==   
                  ==::closes body
              ==:: closes html
                =/  =response-header:http
                    :-  200
                    :~  ['content-type' 'text/html; charset=utf-8']
                    ==
                  :~
                    [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                    [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                    [%give %kick [/http-response/[p.req]]~ ~]
                  ==
            ::
            ++  post-myad-webpage
                |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t mylistings1=(map id=@t advert1) listings1=(map id=@t advert1)]
                ^-  (list card)
                  =/  =response-header:http
                      :-  301
                      :~  ['Location' '/apps/xchange/postad']
                      ==
                  :~
                      [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                      [%give %kick [/http-response/[p.req]]~ ~]
                  ==
              ::
            ++  get-manage-myad 
                |=  [req=(pair @ta inbound-request:eyre) purl-pair=[myad-id=@t id-value=@t] now=@da our=@p eny=@t mylistings=(map id=@t advert) mylistings1=(map id=@t advert1)]
                ^-  (list card)
                =/  a=[id=@t advert1]  [id-value.purl-pair (~(got by mylistings1) id-value.purl-pair)]
                =/  body
                %-  as-octs:mimes:html
                %-  crip
                %-  en-xml:html
                ;html
                  ;head
                    ;title:"Xchange"
                    ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                    ;meta(charset "utf-8");
                    ;meta(name "viewport", content "width=device-width, initial-scale=1");
                    ;style: {style}
                    ;script
                        ; document.addEventListener('DOMContentLoaded', function() {{
                        ;   const maxSize = 2 * 1024 * 1024;
                        ;   const fileInputs = document.querySelectorAll('.file-input');
                        ;   
                        ;   fileInputs.forEach(function(input) {{
                        ;     input.addEventListener('change', function(e) {{
                        ;       const file = e.target.files[0];
                        ;       if (file && file.size > maxSize) {{
                        ;         alert('File ' + file.name + ' is too large. Maximum size is 2MB. Selected file is ' + 
                        ;               (file.size / 1024 / 1024).toFixed(2) + 'MB');
                        ;         e.target.value = '';
                        ;       }}
                        ;     }});
                        ;   }});
                        ;   
                        ;   document.querySelector('form[action="/apps/xchange/postad"]').addEventListener('submit', function(e) {{
                        ;     for (let input of fileInputs) {{
                        ;       const file = input.files[0];
                        ;       if (file && file.size > maxSize) {{
                        ;         e.preventDefault();
                        ;         alert('Please remove files larger than 2MB before submitting');
                        ;         return false;
                        ;       }}
                        ;     }}
                        ;   }});
                        ; }});
                      ==
                  ==:: closes head
                  ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                     ;div.menu-bar
                    ;ul
                      ;li
                        ;a(href "/apps/xchange"): All
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/services"): Services
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/events"): Events
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/jobs"): Jobs
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/for_sale"): For-Sale
                      ==
                    ==
                  ==::closes menu-bar
                  ;div.main-content
                   ;div.left-bar
                    ;ul
                         ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                         ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==                       
                        ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                        ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                    ;div.table-div-ads
            ;form(method "post", action "/apps/xchange/manage-myad", enctype "multipart/form-data")
              ;table.myad-form-table
                ;tr
                  ;div.myad-input-cell
                    ;th(colspan "2", style "text-align: center;"): Update Ad
                  ==  :: Closes title row
                ==
                ;tr(style "display: none;")
                  ;td: Ad Id
                  ;td
                    ;div.myad-input-cell
                      ;input(type "text", name "ad-id", value "{(trip id.a)}");
                      ==
                    ==
                  ==
                ;tr
                  ;td: Title
                    ;td
                      ;div.myad-input-cell
                        ;input(type "text", name "title", value "{(trip ad-title.a)}");
                      ==
                    ==
                ==

                ;tr                 
                    ;td: Date Posted
                      ;div.myad-input-cell
                        ;td: {(trip (get-date when.a))}
                      ==
                ==
              ;tr
                    ;td: Type
                    ;td
                      ;select(name "type", class "dropdown")
                        ;option(value "{(trip type.a)}", selected "selected"): {(trip type.a)}
                        ;option(value "services"): Services
                        ;option(value "events"): Events
                        ;option(value "jobs"): Jobs
                        ;option(value "for_sale"): For Sale
                      ==
                    ==
                  ==

                ;tr
                  ;td: Price
                    ;td
                      ;div.myad-input-cell
                        ;input(type "text", name "price", value "{(trip +.price.a)}");
                      ==
                  ==
                ==

                ;tr
                  ;td: Timezone
                    ;td
                      ;div.myad-input-cell
                        ;input(type "text", name "timezone", value "{(trip +.timezone.a)}");
                      ==
                  ==
                ==
                ;tr
                  ;td: Contact Information
                      ;td
                        ;div.myad-input-cell
                        ;input(type "text", name "contact", value "{(trip contact.a)}");
                      ==
                    ==
                ==

                ;tr
                  ;td: Description
                  ;td
                    ;div.myad-input-cell3lines
                      ;textarea(name "description", rows "5", style "font-size: 18px; width: 100%; resize: vertical;"): {(trip body.a)}
                    ==
                  ==
                ==
                ;tr
                  ;td: Active
                    ;td
                        ;select(name "active", class "dropdown")
                          ;option(value "{(trip (scot %f active.a))}", selected "selected"): {?:(=(active.a %.y) "Yes" "No")}
                          ;option(value "%.y"): Yes
                          ;option(value "%.n"): No
                    ==
                  ==
                ==
                  ;tr
               ;td: Current Images
                ;td
                  ;div
                    ;+  ?~  image1.+.a
                          ;div(style "margin-bottom: 10px;")
                            ;p: "No Image 1 uploaded"
                            ;label: "Add Image 1:"
                            ;input(type "file", name "add-image1", class "file-input");
                          ==
                       ;div(style "margin-bottom: 10px;")
                        ;p: "Image 1: {(trip filename1.u.image1.+.a)}"
                        ;div(style "display: flex; gap: 10px; align-items: center;")
                          ;button(type "button", onclick "document.querySelector('input[name=delete-image1]').value='true'; this.parentElement.parentElement.style.opacity='0.5';", class "file-remove"): Remove Image 1
                          ;input(type "file", name "replace-image1", class "file-input");
                        ==
                        ;input(type "hidden", name "delete-image1", value "false");
                        ;input(type "hidden", name "keep-image1", value "{(trip filename1.u.image1.a)}");
                      ==
                    ;+  ?~  image2.+.a
                          ;div(style "margin-bottom: 10px;")
                            ;p: "No Image 2 uploaded"
                            ;label: "Add Image 2:"
                            ;input(type "file", name "add-image2", class "file-input");
                          ==
                        ;div(style "margin-bottom: 10px;")
                          ;p: "Image 2: {(trip filename2.u.image2.+.a)}"
                          ;div(style "display: flex; gap: 10px; align-items: center;")
                            ;button(type "button", onclick "document.querySelector('input[name=delete-image2]').value='true'; this.parentElement.parentElement.style.opacity='0.5';", class "file-remove"): Remove Image 2
                            ;input(type "file", name "replace-image2", class "file-input");
                          ==
                          ;input(type "hidden", name "delete-image2", value "false");
                          ;input(type "hidden", name "keep-image2", value "{(trip filename2.u.image2.a)}");
                        ==
                  ==
                ==
              ==
                ;tr
                  ;td(colspan "2", style "text-align: center;")
                    ;button(type "submit", class "submit-button"): update ad
                  ==
                ==
              ==
            ==  :: Closes form
          ==  :: Closes div.table-div-listings
          ==
        ==  :: Closes body
      ==  :: Closes html
      =/  =response-header:http
            :-  200
            :~  ['content-type' 'text/html; charset=utf-8']
            ==
          :~
            [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
            [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
            [%give %kick [/http-response/[p.req]]~ ~]
          ==
    ::
    ++  get-manage-alert 
        |=  [req=(pair @ta inbound-request:eyre) purl-pair=[alert-id=@t id-value=@t] now=@da our=@p eny=@t alerts=(map id=@t alert) alert-results=(map ad-id=@t alert-result) listings1=(map id=@t advert1)]
        ^-  (list card)
        =/  a=[id=@t alert]  [id-value.purl-pair (~(got by alerts) id-value.purl-pair)]
        =/  body
        %-  as-octs:mimes:html
        %-  crip
        %-  en-xml:html
        ;html
          ;head
            ;title:"Xchange"
            ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
            ;meta(charset "utf-8");
            ;meta(name "viewport", content "width=device-width, initial-scale=1");
            ;style: {style}
          ==:: closes head
          ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                     ;div.menu-bar
                    ;ul
                      ;li
                        ;a(href "/apps/xchange"): All
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/services"): Services
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/events"): Events
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/jobs"): Jobs
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/for_sale"): For-Sale
                      ==
                    ==
                  ==::closes menu-bar
                  ;div.main-content
                   ;div.left-bar
                    ;ul
                         ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                         ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==                       
                        ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                        ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
        ;div.table-div-alerts
          ;form(method "post", action "/apps/xchange/manage-alert")
            ;table.myad-form-table
              ;tr
                ;th(colspan "2", style "text-align: center;"): Update Alert
              ==  :: Closes title row

              ;tr(style "display: none;")
                ;td: Alert Id
                ;td
                  ;input(type "text", name "alert-id", value "{(trip id.a)}");
                ==
              ==
              ;tr
                ;td: Alert Title
                ;td
                  ;div.alert-input-cell
                    ;input(type "text", name "alert-title", value "{(trip alert-title.a)}", style "font-size: 18px;");
                  ==
                ==
              ==
              ;tr
                ;td: Alert Ad-Title
                  ;td
                    ;div.alert-input-cell
                    ;input(type "text", name "ad-title", value "{(trip ad-title.a)}", style "font-size: 18px;");
                  ==
                ==
              ==
              ;tr
                  ;td: Date Posted
                  ;td(style "font-size: 18px; max-width: 200px; width: 100%;"): {(trip (get-date when.a))}
              ==
              ;tr
                  ;td: Type
                  ;td
                    ;select(name "type", class "dropdown")
                      ;option(value "{(trip type.a)}", selected "selected"): {(trip type.a)}
                      ;option(value "Services"): Services
                      ;option(value "Events"): Events
                      ;option(value "Jobs"): Jobs
                      ;option(value "For Sale"): For Sale
                    ==
                  ==
                ==
              ;tr
                ;td: Alert Price
                ;td
                  ;div.alert-input-cell
                    ;input(type "text", name "price", value "{(trip +.price.a)}", style "font-size: 18px;");
                  ==
                ==
              ==

              ;tr
                ;td: Alert Timezone
                ;td
                  ;div.alert-input-cell
                    ;input(type "text", name "timezone", value "{(trip +.timezone.a)}", style "font-size: 18px;");
                  ==
                ==
              ==

              ;tr
                ;td: Alert Contact Information
                ;td
                  ;div.alert-input-cell
                    ;input(type "text", name "contact", value "{(trip contact.a)}");
                  ==
                ==
              ==
              ;tr
                ;td: Alert Ship
                ;td
                  ;div.alert-input-cell
                    ;input(type "text", name "ship", value "{(trip ship.a)}", style "font-size: 18px;");
                  ==
                ==
              ==
              ;tr
                ;td: Alert Description
                ;td
                  ;div.alert-input-cell
                    ::;input(type "text", name "description", value "{(trip body.a)}", style "font-size: 18px;");
                    ;textarea(name "description", rows "5", style "font-size: 18px; width: 100%; resize: vertical;"): {(trip body.a)}
                  ==
                ==
              ==       
              ;tr
                ;td: Alert Active
                ;td
                  ;select(name "active", class "dropdown")
                    ;option(value "{(trip (scot %f active.a))}", selected "selected"): {?:(=(active.a %.y) "Yes" "No")}
                    ;option(value "%.y"): Yes
                    ;option(value "%.n"): No
                  ==
                ==
              ==

                ;tr
                  ;td(colspan "2", style "text-align: center;")
                    ;button(type "submit", class "submit-button"): update alert
                  ==
                ==
              ==
            ==  :: Closes form
          ==  :: Closes div.table-div-listings
        ==
    ==  :: Closes body
  ==  :: Closes html
      =/  =response-header:http
            :-  200
            :~  ['content-type' 'text/html; charset=utf-8']
            ==
          :~
            [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
            [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
            [%give %kick [/http-response/[p.req]]~ ~]
          ==
    ::
    ++  get-view-alert 
        |=  [req=(pair @ta inbound-request:eyre) purl-pair=[alert-id=@t id-value=@t] now=@da our=@p eny=@t alerts=(map id=@t alert) alert-results=(map ad-id=@t alert-result) listings1=(map id=@t advert1)]
        ^-  (list card)
        =/  alert-id-result  (~(get by alerts) id-value.purl-pair)
        =/  alert-results-list 
            %+  skim
            ~(tap by alert-results)
            |=  [ad-id=@t ar=alert-result]
            =(alert-id.ar id-value.purl-pair)
        =/  body
        %-  as-octs:mimes:html
        %-  crip
        %-  en-xml:html
        ;html
          ;head
            ;title:"Xchange"
            ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
            ;meta(charset "utf-8");
            ;meta(name "viewport", content "width=device-width, initial-scale=1");
            ;style: {style}
          ==:: closes head
          ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                     ;div.menu-bar
                    ;ul
                      ;li
                        ;a(href "/apps/xchange"): All
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/services"): Services
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/events"): Events
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/jobs"): Jobs
                      ==
                      ;li
                        ;a(href "/apps/xchange/type/for_sale"): For-Sale
                      ==
                    ==
                  ==::closes menu-bar
                  ;div.main-content
                   ;div.left-bar
                    ;ul
                        ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==
                        ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                        ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar             
                ;div.table-div-alert-results
                    ;table
                       
                      ;tr
                          ;th: Thumbnail
                          ;th: Ad-Title
                          ;th: Date
                          ;th: Type
                          ;th: Price
                          ;th: Timezone
                          ;th: Contact
                          ;th: Ship
                          ;th: Description
                      ==:: closes tr
                        ;*  %+  turn  alert-results-list
                        |=  a=[ad-id=@t [ad-title=@t when=@da type=@t price=(unit @t) timezone=(unit @t) contact=@t ship=@p body=@t active=? alert-id=@t]]
                          =/  ad-lookup  (~(get by listings1) ad-id.a)
                          ;tr
                            ;td(style "display: none;"): {(trip ad-id.a)}
                            ;td(style "text-align: center; vertical-align: middle;")
                              ;+  ?~  ad-lookup
                                ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                              ?~  image1.u.ad-lookup
                                ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                              ?:  =(filename1.u.image1.u.ad-lookup '')
                                ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                                ;img(src "/apps/xchange/img/listing/{(trip ad-id.a)}/1", alt "Thumbnail", style "max-width: 80px; max-height: 80px; object-fit: cover; border-radius: 4px;");
                              ==
                            ;td
                                  ;a(href "/apps/xchange/view-ad?ad-id={(trip ad-id.a)}"): {?:((gth (lent (trip ad-title.a)) 60) (weld (scag 60 (trip ad-title.a)) "...") (trip ad-title.a))}
                                  ==
                            ;td: {(trip (get-date when.a))}
                            ;td: {(trip type.a)}
                            ;td: {?:((gth (lent (trip +.price.a)) 60) (weld (scag 60 (trip +.price.a)) "...") (trip +.price.a))}
                            ;td: {?:((gth (lent (trip +.timezone.a)) 60) (weld (scag 60 (trip +.timezone.a)) "...") (trip +.timezone.a))}
                            ;td: {?:((gth (lent (trip contact.a)) 60) (weld (scag 60 (trip contact.a)) "...") (trip contact.a))}
                            ;td
                                    ;+  ?:  (~(has by my-favorites.state) ship.a)
                                          ;div
                                            ;span(style "color: green; font-size: 32px;"): ♥
                                            ;span: {(trip (scot %p ship.a))}
                                          ==
                                        ?:  (~(has by my-avoids.state) ship.a)
                                          ;div
                                            ;span(style "color: black; font-size: 32px;"): ❌
                                            ;span: {(trip (scot %p ship.a))}
                                          ==
                                        ;span: {(trip (scot %p ship.a))}
                                    ==
                            ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 200px; white-space: normal;"): {?:((gth (lent (trip body.a)) 60) (weld (scag 60 (trip body.a)) "...") (trip body.a))}
                          ==    
                  ==::closes table
                ==::closes div-table
            ==::main-content
          ==  :: Closes body
        ==  :: Closes html
      =/  =response-header:http
            :-  200
            :~  ['content-type' 'text/html; charset=utf-8']
            ==
          :~
            [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
            [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
            [%give %kick [/http-response/[p.req]]~ ~]
          ==
    ::
    ++  post-myad-state
        |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t mylistings=(map id=@t advert) mylistings1=(map id=@t advert1) listings=(map id=@t advert) listings1=(map id=@t advert1) alerts=(map alert-id=@t alert) alert-results=(map ad-id=@t alert-result) message-myads=@t maxpic-size=@ud]
        ^+  state
        =/  data=octs  +.body.request.q.req
        ::=/  preview  `@t`(cut 3 [0 2.200] (swp 3 q.data))::  last 2200 bytes
        ::=/  preview  `@t`(cut 3 [0 1.200] q.data):: first 1200 bytes
        ::~&  [%preview preview]
        :: Simple string search function
        =/  find-field
        |=  [field-name=@t data=@]  :: Changed data=@t to data=@
        ^-  @t
        =/  field-name-binary  `@`field-name
        =/  search-pattern  
            %+  can  3
            :~  [6 `@`'name="']                           :: "name=\"" (6 bytes)
                [(met 3 field-name-binary) field-name-binary]  :: fieldname
                [5 `@`'"\0d\0a\0d\0a']                    :: "\"\r\n\r\n (5 bytes)
            ==
        =/  pattern-len  (met 3 search-pattern)
        =/  data-len  (met 3 data)
        =/  crlf  `@`'\0d\0a'
        =/  i  0
        |-
        ?:  (gte (add i pattern-len) data-len)  ''  :: Not found
        =/  slice  (cut 3 [i pattern-len] data)
        ?:  =(slice search-pattern)
          :: Found the pattern, now extract the value
          =/  value-start  (add i pattern-len)
          =/  j  value-start
          |-
          ?:  (gte (add j 2) data-len)  
            `@t`(cut 3 [value-start (sub data-len value-start)] data)  :: Convert to @t
          =/  check  (cut 3 [j 2] data)
          ?:  =(check crlf)
            `@t`(cut 3 [value-start (sub j value-start)] data)  :: Convert to @t
          $(j +(j))
        $(i +(i))
        ::
        =/  find-textarea-field
          |=  [field-name=@t data=@]
          ^-  @t
          =/  field-name-binary  `@`field-name
          =/  search-pattern  
              %+  can  3
              :~  [6 `@`'name="']
                  [(met 3 field-name-binary) field-name-binary]
                  [5 `@`'"\0d\0a\0d\0a']
              ==
          =/  pattern-len  (met 3 search-pattern)
          =/  data-len  (met 3 data)
          =/  boundary-pattern  `@`'\0d\0a------'  :: Look for boundary instead of just CRLF
          =/  i  0
          |-
          ?:  (gte (add i pattern-len) data-len)  ''
          =/  slice  (cut 3 [i pattern-len] data)
          ?:  =(slice search-pattern)
            =/  value-start  (add i pattern-len)
            =/  j  value-start
            |-
            ?:  (gte (add j 8) data-len)  
              `@t`(cut 3 [value-start (sub data-len value-start)] data)
            =/  check  (cut 3 [j 8] data)
            ?:  =(check boundary-pattern)  :: Stop at next form boundary
              `@t`(cut 3 [value-start (sub j value-start)] data)
            $(j +(j))
          $(i +(i))
        :: Function to find filename in file upload fields
        =/  find-filename
          |=  [field-name=@t data=@]
          ^-  @t
          =/  field-name-binary  `@`field-name 
          =/  search-pattern  
                %+  can  3
                :~  [6 `@`'name="']
                    [(met 3 field-name-binary) field-name-binary]
                ==
          =/  pattern-len  (met 3 search-pattern)
          =/  data-len  (met 3 data)
          =/  i  0
          |-
          ?:  (gte (add i pattern-len) data-len)  ''  :: Not found
          =/  slice  (cut 3 [i pattern-len] data)
          ?:  =(slice search-pattern)
            :: Found the field, now look for filename= on the same line
            =/  line-start  i
            =/  j  (add i pattern-len)
            |-
            ?:  (gte (add j 10) data-len)  ''  :: filename= not found
            =/  check  (cut 3 [j 10] data)
            ?:  =(check `@`'filename="')
              :: Found filename=", extract until closing quote
              =/  filename-start  (add j 10)
              =/  k  filename-start
              |-
              ?:  (gte k data-len)  ''
              =/  char  (cut 3 [k 1] data)
              ?:  =(char `@`'"')
                `@t`(cut 3 [filename-start (sub k filename-start)] data)
              $(k +(k))
            =/  char  (cut 3 [j 1] data)
            ?:  =(char `@`'\0d')  ''  :: End of line, filename not found
            $(j +(j))
          $(i +(i))
        =/  find-content-type
            |=  [field-name=@t data=@]
            ^-  @t
            =/  field-name-binary  `@`field-name 
            =/  search-pattern  
                %+  can  3
                :~  [6 `@`'name="']
                    [(met 3 field-name-binary) field-name-binary]
                    [1 `@`'"']
                ==
            =/  pattern-len  (met 3 search-pattern)
            =/  data-len  (met 3 data)
            =/  i  0
            |-
            ?:  (gte (add i pattern-len) data-len)  ''
            =/  slice  (cut 3 [i pattern-len] data)
            ?:  =(slice search-pattern)
              =/  j  (add i pattern-len)
              =/  section-end
                =/  k  j
                |-
                ?:  (gte (add k 6) data-len)  data-len
                =/  boundary-check  (cut 3 [k 6] data)
                ?:  =(boundary-check `@`'------')  k
                $(k +(k))
              |-
              ?:  (gte (add j 14) section-end)  ''
              =/  check  (cut 3 [j 14] data)
              ?:  =(check `@`'Content-Type: ')
                =/  value-start  (add j 14)
                =/  m  value-start
                |-
                ?:  (gte (add m 2) section-end)  
                  `@t`(cut 3 [value-start (sub section-end value-start)] data)  :: CONVERT TO @t
                =/  check-end  (cut 3 [m 2] data)
                ?:  =(check-end `@`'\0d\0a')
                  `@t`(cut 3 [value-start (sub m value-start)] data)  :: CONVERT TO @t
                $(m +(m))
              $(j +(j))
            $(i +(i))
          :: Extract file content (binary data after headers)
        =/  find-file-content-with-size
            |=  [field-name=@t data=@]
            ^-  [file-data=@ file-size=@ud]          
            =/  field-name-binary  `@`field-name
            ::define search pattern
            =/  search-pattern  
              %+  can  3
              :~  [6 `@`'name="']                           :: "name=\"" (6 bytes)
                  [(met 3 field-name-binary) field-name-binary]  :: fieldname
                  [1 `@`'"']                                :: "\"" (1 byte)
              == 
            =/  pattern-len  (met 3 search-pattern)::the number of bytes in search pattern
            =/  data-len  (met 3 data)::the number of bytes in the data blob
            =/  double-crlf  `@`'\0d\0a\0d\0a'::\r\n\r\n - the real data starts right after this
            =/  i  0

            :: Find the field
            |-
            ?:  (gte (add i pattern-len) data-len)  [0 0]  :: Return [0 0] for both values
            =/  slice  (cut 3 [i pattern-len] data)::extracts a slice of bytes from the binary data for pattern matching:
            ?:  =(slice search-pattern)
              :: Found the field, now find the double CRLF that starts the file content
              =/  j  (add i pattern-len)
              |-
              ?:  (gte (add j 4) data-len)  [0 0]  :: Return [0 0] for both values
              =/  check  (cut 3 [j 4] data)
              ?:  =(check double-crlf)
                :: Found file content start (after the double CRLF-\r\n\r\n)
                =/  content-start  (add j 4)
                :: Now find the end - look for the next boundary preceded by \r\n
                =/  k  content-start
                |-
                ?:  (gte (add k 8) data-len)  
                  :: No more boundaries, content goes to end (minus final \r\n)
                  =/  final-end  (sub data-len 2)
                  =/  file-content  (cut 3 [content-start (sub final-end content-start)] data)
                  [file-content `@ud`(sub final-end content-start)]  :: Return both content and size
                :: Look for \r\n------ pattern (CRLF + boundary start)
                =/  boundary-pattern  `@`'\0d\0a------'
                =/  boundary-check  (cut 3 [k 8] data)
                ?:  =(boundary-check boundary-pattern)
                  :: Found end of file content (excluding the \r\n before boundary)
                  =/  file-content  (cut 3 [content-start (sub k content-start)] data)
                  [file-content `@ud`(sub k content-start)]  :: Return both content and size
                $(k +(k))
              $(j +(j))
            $(i +(i))
        ::
        :: Function to check if filename has valid image extension
        =/  is-valid-image-extension
          |=  filename=@t
          ^-  ?
          ?:  =(filename '')  %.y  :: Empty filename is valid (no file uploaded)
          =/  filename-len  (met 3 filename)
          ?:  (lth filename-len 4)  %.n  :: Too short to have .jpg/.png
          =/  last-4  (cut 3 [(sub filename-len 4) 4] filename)
          =/  last-5  ?:  (lth filename-len 5)  ''  (cut 3 [(sub filename-len 5) 5] filename)
          ?|  =(last-4 '.jpg')
              =(last-4 '.png')
              =(last-4 '.JPG')
              =(last-4 '.PNG')
              =(last-5 '.jpeg')
              =(last-5 '.JPEG')
          ==
        ::
        =/  ad-id
        ~>  %bout
          (find-field 'ad-id' +.data)
        =/  ad-id  ?~(ad-id eny ad-id)
        =/  existing-ad  (~(get by mylistings1) ad-id)  :: Get existing ad AFTER ad-id is finalized
        =/  is-existing-ad  ?=(^ existing-ad)
        =/  image1-field-name  ?:  is-existing-ad  'replace-image1'  'image1'
        =/  image2-field-name  ?:  is-existing-ad  'replace-image2'  'image2'
        =/  adtitle  (find-field 'title' +.data)
        =/  adtype  (find-field 'type' +.data) 
        =/  adprice  (find-field 'price' +.data)
        =/  adtimezone  (find-field 'timezone' +.data)
        =/  adcontact  (find-field 'contact' +.data)
        =/  addescription  (find-textarea-field 'description' +.data)
        =/  adstatus  ?:  =((find-field 'active' +.data) '%.y')  %.y  %.n
        =/  max-file-size  `@ud`(mul maxpic-size (mul 1.024 1.024))  :: limit (maxpic-size * 1024 * 1024 bytes)
        =/  binary-data  +.data 
        =/  adfilename1  (find-filename image1-field-name +.data)
        =/  adfilename2  (find-filename image2-field-name +.data)
        :: Check file extensions
          ?:  !(is-valid-image-extension adfilename1)
            =/  error-body  'Error: Image 1 must be a PNG or JPG file'
            state(message-myads error-body)
          ?:  !(is-valid-image-extension adfilename2)
            =/  error-body  'Error: Image 2 must be a PNG or JPG file'
            state(message-myads error-body)
        =/  adcontenttype1  (find-content-type image1-field-name +.data)
        =/  adcontenttype2  (find-content-type image2-field-name +.data)
        =/  [adfile1=@ adfile1-size=@ud]  (find-file-content-with-size image1-field-name binary-data)
        =/  [adfile2=@ adfile2-size=@ud]  (find-file-content-with-size image2-field-name binary-data)
        ?:  (gth adfile1-size max-file-size)
          :: Handle file1 too large error - return error response
          =/  error-body  
                %-  crip
                %+  weld  "Error: Image 1 file size exceeds "
                %+  weld  (trip (scot %ud maxpic-size))
                " MB max picture size limit"
          state(message-myads error-body)
        ?:  (gth adfile2-size max-file-size)
          :: Handle file1 too large error - return error response
          =/  error-body  
              %-  crip
              %+  weld  "Error: Image 2 file size exceeds "
              %+  weld  (trip (scot %ud maxpic-size))
        " MB max picture size limit"
          state(message-myads error-body)
        =/  image1-info
          ?:  =(adfilename1 '')
            ?~  existing-ad  ~  image1.u.existing-ad  
          `[adfilename1 adcontenttype1 [adfile1-size adfile1]]
        =/  image2-info
          ?:  =(adfilename2 '')
            ?~  existing-ad  ~  image2.u.existing-ad  
          `[adfilename2 adcontenttype2 [adfile2-size adfile2]]
        =/  new-advert  [adtitle now adtype [~ adprice] [~ adtimezone] adcontact our addescription adstatus]
        =/  new-advert1  [adtitle now adtype [~ adprice] [~ adtimezone] adcontact our addescription adstatus image1-info image2-info]
        =/  newlistings  ?:  =(%.y adstatus)
                          (~(put by listings) ad-id new-advert)
                          (~(del by listings) ad-id)
        =/  newlistings1  ?:  =(%.y adstatus)
                          (~(put by listings1) ad-id new-advert1)
                          (~(del by listings1) ad-id)                  
        =/  newmylistings  (~(put by mylistings) ad-id new-advert)  :: Update `mylistings`
        =/  newmylistings1  (~(put by mylistings1) ad-id new-advert1)  :: Update `mylistings`
        =/  new-alert-results  (alert-matches alerts newmylistings1)
        =/  success-message  'Ad Added Successfully'
        state(mylistings newmylistings, listings newlistings, mylistings1 newmylistings1, listings1 newlistings1, alert-results new-alert-results, message-myads success-message)
                    ::
    ::
    ++  update-myalert-state
      |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t alerts=(map id=@t alert) listings=(map id=@t advert) listings1=(map id=@t advert1) alert-results=(map ad-id=@t alert-result)]
        ^+  state
        =/  data=octs  +.body.request.q.req
        =/  text-data  (crip (trip +.data))
        =/  parsedata  (need (rush text-data yquy:de-purl:html))
        =/  new-alertid  (snag 0 parsedata)
        =/  new-alert-title  (snag 1 parsedata)
        =/  new-alert-adtitle  (snag 2 parsedata)
        =/  new-alert-type  (snag 3 parsedata)
        =/  new-alert-price  (snag 4 parsedata)
        =/  new-alert-timezone  (snag 5 parsedata)
        =/  new-alert-contact  (snag 6 parsedata)
        =/  new-alert-ship  (snag 7 parsedata)
        =/  new-alert-description  (snag 8 parsedata)
        =/  raw-status  (snag 9 parsedata)  :: parse logical as a cord 
        =/  new-alert-status  ?:  =(+.raw-status '%.y')  %.y  %.n  :: Compare & convert to @f
        =/  newpair  [+.new-alertid [+.new-alert-title +.new-alert-adtitle now +.new-alert-type [~ +.new-alert-price] [~ +.new-alert-timezone] +.new-alert-contact +.new-alert-ship +.new-alert-description new-alert-status]]
        =/  newalerts  (~(put by alerts) newpair)
        =/  new-alert-results  (alert-matches newalerts listings1)
            state(alerts newalerts, alert-results new-alert-results)
        ::
        ::
    ++  delete-alert-webpage
      |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t alerts=(map alert-id=@t alert)]
      ^-  (list card)
      =/  =response-header:http
        :-  303
        :~  ['location' '/apps/xchange/alert']
        ==
      :~
        [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
        [%give %kick [/http-response/[p.req]]~ ~]
      ==
  ::
    ++  delete-myad-webpage
        |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t mylistings=(map myad-id=@t advert)]
        ^-  (list card)
        =/  =response-header:http
          :-  303
          :~  ['location' '/apps/xchange/postad']
          ==
        :~
          [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
          [%give %kick [/http-response/[p.req]]~ ~]
        ==
    ::
    ++  delete-alert-state
      |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t alerts=(map alert-id=@t alert) alert-results=(map ad-id=@t alert-result)]
      ^+  state
      =/  data=octs  +.body.request.q.req
      =/  text-data  (crip (trip +.data))
      =/  parsedata  (need (rush text-data yquy:de-purl:html))
      =/  alert-id  (snag 0 parsedata)
      ::  Remove the alert from alerts map
      =/  updated-alerts  (~(del by alerts) +.alert-id)
      ::  Filter alert-results to remove all entries with this alert-id
      =/  updated-alert-results
        %-  malt
        %+  skip
          ~(tap by alert-results)
          |=  [ad-id=@t result=alert-result]
          =(alert-id.result +.alert-id)
      ::  Clean up orphaned alert-results (where alert-id doesn't exist in updated-alerts)
      =/  cleaned-alert-results
        %-  malt
        %+  skip
          ~(tap by updated-alert-results)
          |=  [ad-id=@t result=alert-result]
          =(~ (~(get by updated-alerts) alert-id.result))
      ::  Return state with both maps updated
      state(alerts updated-alerts, alert-results cleaned-alert-results)
      ::
    ++  delete-myad-state
        |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t mylistings=(map myad-id=@t advert) mylistings1=(map myad-id=@t advert1) listings=(map ad-id=@t advert) listings1=(map ad-id=@t advert1)]
        ^+  state
        =/  data=octs  +.body.request.q.req
        =/  text-data  (crip (trip +.data))
        =/  parsedata  (need (rush text-data yquy:de-purl:html))
        =/  myad-id  (snag 0 parsedata)
        %=  state
            mylistings1  (~(del by mylistings1.state) +.myad-id)
            listings1    (~(del by listings1.state) +.myad-id)
          ==
::
    ++  get-myad-id-from-request
      |=  req=(pair @ta inbound-request:eyre)
      ^-  @t
      =/  data=octs  +.body.request.q.req
      =/  text-data  (crip (trip +.data))
      =/  parsedata  (need (rush text-data yquy:de-purl:html))
      =/  myad-id-pair  (snag 0 parsedata)
      =/  myad-id  +.myad-id-pair
          myad-id
      ::
    ++  get-active-listings
      |=  mylistings1=(map @t advert1)
      %-  malt
      %+  turn
        %+  skim
          ~(tap by mylistings1)
          |=  [key=@t value=advert1]
          =(active.value %.y)
        |=  [key=@t value=advert1]
        [key value]
      ::
      ++  get-inactive-listings
      |=  mylistings1=(map @t advert1)
      %-  malt
      %+  turn
        %+  skim
          ~(tap by mylistings1)
          |=  [key=@t value=advert1]
          =(active.value %.n)
        |=  [key=@t value=advert1]
        [key value]
      ::
    ::
     ++  alert-matches
        |=  [alerts=(map alert-id=@t alert) listings1=(map id=@t advert1)]
        ^-  (map ad-id=@t alert-result)
        %-  malt
        %-  zing
        %+  turn  ~(tap by alerts)
        |=  [alert-id=@t a=alert]
        %+  turn
          %+  skim  ~(tap by listings1)
          |=  [id=@t ad=advert1]
          ^-  ?
          ?&
            ?:  =(ad-title.a '')  %.y  !=(~ (fand (cass (trip ad-title.a)) (cass (trip ad-title.ad))))
            ?:  =(type.a '')  %.y  !=(~ (fand (cass (trip type.a)) (cass (trip type.ad))))
            =(active.a %.y)
            =(active.ad %.y)
            ?:  ?=(~ +.price.a)  %.y  ?:  ?=(~ +.price.ad)  %.n  !=(~ (fand (cass (trip u.price.a)) (cass (trip u.price.ad))))
            ?:  ?=(~ +.timezone.a)  %.y  ?:  ?=(~ +.timezone.ad)  %.n  !=(~ (fand (cass (trip u.timezone.a)) (cass (trip u.timezone.ad))))
            ?:  =(contact.a '')  %.y  !=(~ (fand (trip contact.a) (trip contact.ad)))
            ?:  =(ship.a ~)  %.y  =(ship.a (scot %p ship.ad))  :: Keep exact match for ship
            ?:  =(body.a '')  %.y  !=(~ (fand (cass (trip body.a)) (cass (trip body.ad))))
          ==
        |=  [id=@t ad=advert1]
        ^-  [ad-id=@t alert-result]
        :-  id
        :*
          ad-title.ad
          when.ad
          type.ad
          price.ad
          timezone.ad
          contact.ad
          ship.ad
          body.ad
          active.ad
          alert-id
        ==

       ++  search-matches
          |=  [search-term=@t listings=(map id=@t advert1)]
          ^-  (map ad-id=@t advert1)
          %-  malt
          %+  skim  ~(tap by listings)
          |=  [id=@t ad=advert1]
          ^-  ?
          =/  term-lower  (cass (trip search-term))
          ?|
            !=(~ (fand term-lower (cass (trip ad-title.ad))))
            !=(~ (fand term-lower (cass (trip type.ad))))
            !=(~ (fand term-lower (cass (trip contact.ad))))
            !=(~ (fand term-lower (cass (trip body.ad))))
            ?&(?=(^ price.ad) !=(~ (fand term-lower (cass (trip u.price.ad)))))
            ?&(?=(^ timezone.ad) !=(~ (fand term-lower (cass (trip u.timezone.ad)))))
            =(search-term (scot %p ship.ad))
          ==
    ::
   ++  send-hark
    |=  [who=ship msg=cord now=@da eny=@uvH]
    =/  body=(list content:hark)  ~[msg]
    =/  id  (end 7 (shas %xchange eny))
    =/  rope  [~ ~ %xchange /xchange]  :: Masquerade as landscape
    =/  =yarn:hark
      [id=id rop=rope tim=now con=body wer=/apps/xchange but=~]
    =/  action  [%add-yarn all=& desk=& yarn]
    =/  cage  [%hark-action !>(action)]
    [%pass /hark %agent [who %hark] %poke cage]
        ::
    
       ++  static
          |%
          ++  serve-static-file
            |=  [url-path=(list @ta) req=(pair @ta inbound-request:eyre) our=@p now=@da]
            ^-  (list card)
            ::~&  [%url-path url-path]            ::  Use the correct Clay path format
            =/  clay-path  
            :(weld /(scot %p our)/xchange/(scot %da now) url-path)
            ::  First check if file exists using %cy
            =/  file-arch  .^(arch %cy /(scot %p our)/xchange/(scot %da now)/img/xchange-logo/png)
            ?~  -.file-arch
              ::  File not found - return 404
              =/  =response-header:http
                :-  404
                :~  ['content-type' 'text/plain']
                ==
              =/  body  (as-octs:mimes:html 'File not found')
              :~
                [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                [%give %kick [/http-response/[p.req]]~ ~]
              ==
            ::  File exists - try to serve it using mole to catch failures
            =/  file-data
              %-  mole  |.
              .^(@ %cx clay-path)
            ?~  file-data
              ::  %cx failed (probably too large) - redirect to Clay's HTTP interface
              =/  =response-header:http
                :-  302
                :~  ['location' '/~/clay/xchange/img/xchange-logo/png']
                ==
              :~
                [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                [%give %kick [/http-response/[p.req]]~ ~]
              ==
            ::  File loaded successfully - serve it
            =/  =response-header:http
              :-  200
              :~  ['content-type' 'image/png']
                  ['cache-control' 'public, max-age=3600']
              ==
             =/  file-octs  [(met 3 u.file-data) u.file-data]
            :~
              [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
              [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`file-octs)]
              [%give %kick [/http-response/[p.req]]~ ~]
            ==
          --
    ::
   ++  serve-listing-image
      |=  [req=(pair @ta inbound-request:eyre) purl-pair=[ad-id=@t img-num=@t] now=@da our=@p eny=@t listings1=(map id=@t advert1) mylistings1=(map id=@t advert1)]
      ^-  (list card)
      =/  ad-id  -.purl-pair
      =/  img-num  +.purl-pair
      ::  First try mylistings1, then fallback to listings1
      =/  advert-maybe  
        ?~  m1=(~(get by mylistings1) ad-id)
          (~(get by listings1) ad-id)
        m1
      ::
      ?~  advert-maybe
        ::  Ad not found - return 404
        :_  ~
        [%give %fact ~[/http-response/[-.req]] %http-response-header !>([404 ['Content-Type' 'text/plain'] ~])]
      ::
      =/  advert  u.advert-maybe
      ::  Determine which image to serve based on img-num
      =/  image-data=(unit [filename=@t content-type=@t body=octs])
        ?+    img-num  ~
            %'1'
          ?~  image1.advert  ~
          `[filename1.u.image1.advert content-type1.u.image1.advert body1.u.image1.advert]
        ::
            %'2'  
          ?~  image2.advert  ~
          `[filename2.u.image2.advert content-type2.u.image2.advert body2.u.image2.advert]
        ==
      ::
      ?~  image-data
        ::  Image not found - return 404
        :_  ~
        [%give %fact ~[/http-response/[-.req]] %http-response-header !>([404 ['Content-Type' 'text/plain'] ~])]
      ::
      =/  [filename=@t content-type=@t body=octs]  u.image-data
      ::  Return the image with proper headers
      :~  [%give %fact ~[/http-response/[-.req]] %http-response-header !>([200 ~[['Content-Type' content-type] ['Content-Length' (scot %ud p.body)] ['Access-Control-Allow-Origin' '*']]])]
          [%give %fact ~[/http-response/[-.req]] %http-response-data !>(`body)]
          [%give %kick ~[/http-response/[-.req]] ~]
      ==
    ::
    ++  get-view-ad
        |=  [req=(pair @ta inbound-request:eyre) purl-pair=[ad-id=@t id-value=@t] now=@da our=@p eny=@t mylistings=(map myad-id=@t advert) mylistings1=(map myad-id=@t advert1) listings=(map myad-id=@t advert) listings1=(map myad-id=@t advert1)]
        ^-  (list card)
        =/  listinginfo   ^-  (unit advert1)
            ?~  (~(get by mylistings1) id-value.purl-pair)
                (~(get by listings1) id-value.purl-pair)
                (~(get by mylistings1) id-value.purl-pair)
        =/  body
        %-  as-octs:mimes:html
        %-  crip
        %-  en-xml:html
         ;html
            ;head
              ;title:"Xchange"
              ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
              ;meta(charset "utf-8");
              ;meta(name "viewport", content "width=device-width, initial-scale=1");
              ;style: {style}
            ==:: closes head
            ;body
              ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                ::
                ;div.main-content
                   ;div.left-bar
                    ;ul
                        ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                        ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==
                         ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                        ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                  ;div.alert-wrapper                   
                   ;*  ?~  listinginfo
                        ~
                        :~  ;div  :: Images section - always present, but conditionally populated
                              ;*  ?~  image1.u.listinginfo
                                    ~
                                    :~  ;div(class "ad-images-container")
                                          ;img(src "/apps/xchange/img/listing/{(trip id-value.purl-pair)}/1", alt "Ad Image 1", style "max-width: 600px; max-height: 600px; object-fit: cover; border-radius: 4px;");
                                          ;*  ?~  image2.u.listinginfo
                                                ~
                                                :~  ;img(src "/apps/xchange/img/listing/{(trip id-value.purl-pair)}/2", alt "Ad Image 2", style "max-width: 600px; max-height: 600px; object-fit: cover; border-radius: 4px;");
                                                ==
                                        ==
                                        ;div.spacer
                                          ;br;
                                          ;br;
                                        ==
                                    ==
                            ==
                            ;div(class "ad-description-wrapper")
                              ;div(class "ad-description-container")
                                ;div(class "ad-description-header")
                                  ;h3(class "ad-description-title"): Description
                                ==
                                ;div(class "ad-description-body")
                                  ;div(class "ad-description-text"): {(trip body.u.listinginfo)}
                                ==
                              ==
                            ==
                            ;div(class "ad-details-wrapper")
                              :: Left column
                              ;div(class "ad-details-column")
                                ;table(class "ad-details-table")
                                  ;tr
                                    ;th(class "ad-details-cell"): Price:
                                    ;th(class "ad-details-cell"): {?~(price.u.listinginfo "No price listed" (trip u.price.u.listinginfo))}
                                  ==
                                  ;tr
                                    ;th(class "ad-details-cell"): Date Posted:
                                    ;th(class "ad-details-cell"): {(trip (get-date when.u.listinginfo))}
                                  ==
                                  ;tr
                                    ;th(class "ad-details-cell"): Type of Ad:
                                    ;th(class "ad-details-cell"): {(trip type.u.listinginfo)}
                                  == 
                                ==
                              ==
                              :: Right Column
                              ;div(class "ad-details-column")
                                ;table(class "ad-details-table")
                                  ;tr
                                    ;th(class "ad-details-cell ad-details-label"): Timezone:
                                    ;th(class "ad-details-cell ad-details-value"): {?~(timezone.u.listinginfo "No timezone listed" (trip u.timezone.u.listinginfo))}
                                  ==
                                  ;tr
                                    ;th(class "ad-details-cell ad-details-label"): Contact:
                                    ;th(class "ad-details-cell ad-details-value"): {(trip contact.u.listinginfo)}
                                  ==
                                  ;tr
                                    ;th(class "ad-details-cell ad-details-label"): Ship:
                                    ;th(class "ad-details-cell ad-details-value"): {(trip (scot %p ship.u.listinginfo))}
                                  ==
                                ==
                              ==
                            ==
                            ==
                          ==
                          ==              
                        ==  :: Closes body
                      ==  :: Closes html
                      =/  =response-header:http
                        :-  200
                        :~  ['content-type' 'text/html; charset=utf-8']
                        ==
                      :~
                        [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                        [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                        [%give %kick [/http-response/[p.req]]~ ~]
                      ==

    ::
     ::
     ++  get-pals
          |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t my-avoids=(map ship=@p my-avoid) my-favorites=(map ship=@p comment=@t) message-pals=@t]
          ^-  (list card)
          ::=/  message-pals  ''
          =/  body
            %-  as-octs:mimes:html
            %-  crip
            %-  en-xml:html
            ;html
              ;head
                ;title:"Xchange"
                ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                ;meta(charset "utf-8");
                ;meta(name "viewport", content "width=device-width, initial-scale=1");
                ;style: {style}
              ==::closes head
                ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                ::
                ;div.main-content
                   ;div.left-bar
                    ;ul
                        ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                        ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==
                         ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                        ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                ;div.pals-wrapper   
                    ;+  ?:  =(message-pals '')
                      ;div;
                    ::
                    =/  search-result  (find "successfully" (trip message-pals))
                    =/  contains-success  ?=(^ search-result)
                    =/  bg-color  ?:(contains-success "#d4edda" "#f8d7da")
                    =/  border-color  ?:(contains-success "#c3e6cb" "#f5c6cb")
                    =/  text-color  ?:(contains-success "#155724" "#721c24")
                    ;div(style "display: flex; justify-content: center; margin: 20px 0;")
                      ;div(style "width: 75%; padding: 15px; text-align: center; background: {bg-color}; border: 1px solid {border-color}; border-radius: 4px; color: {text-color}; font-size: 18px;")
                        ;p: {(trip message-pals)}
                      ==
                    ==

                    ;div(style "display: flex; justify-content: center; align-items: flex-start; margin: 20px; gap: 20px;")
                    :: Left column - My Favorites
                      ;div(style "flex: 1; min-width: 0; display: flex; justify-content: center; padding: 20px 10px 0 10px;")
                        ;+  ?:  =(my-favorites ~)
                          ;div.table-div(style "background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); max-width: 75%;")
                            ;table(style "width: 75%; border-collapse: collapse; margin: 0 auto;")
                              ;tr
                                ;th(colspan "3", style "text-align: center; padding: 10px; background: #f5f5f5; border: 1px solid #ddd;"): My Favorites
                              ==
                              ;tr
                                ;td(colspan "3", style "padding: 10px; border: 1px solid #ddd; text-align: center;")
                                  ;form(method "POST", action "/apps/xchange/add-favorite", style "display: flex; flex-direction: column; gap: 10px; align-items: center;")
                                    ;div(style "display: flex; gap: 10px; align-items: center;")
                                      ;input(type "text", name "ship", placeholder "Enter ship name", style "padding: 5px; border: 1px solid #ccc; border-radius: 4px; font-size: 1.25rem");
                                      ;input(type "text", name "comment", placeholder "Comment (optional)", style "padding: 5px; border: 1px solid #ccc; border-radius: 4px; font-size: 1.25rem");
                                      ;button(type "submit", style "padding: 5px 10px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1.25rem"): Add
                                    ==
                                  ==
                                ==
                              ==
                              ;tr
                                ;th(style "padding: 8px; border: 1px solid #ddd; text-align: left; font-size: 1.75rem"): Ship
                                ;th(style "padding: 8px; border: 1px solid #ddd; text-align: left; font-size: 1.75rem"): Comment
                                ;th(style "padding: 8px; border: 1px solid #ddd; text-align: left; font-size: 1.75rem"): Actions
                              ==
                              ;tr
                                ;td#empty-row(colspan "3", style "padding: 20px; text-align: center; border: 1px solid #ddd; font-size: 20px;")
                                  ;p: No Favorites
                                ==
                              ==
                            ==
                          ==
                        ::
                        =/  favorites-list  ~(tap by my-favorites)
                        ;div.table-div(style "background: white; padding: 1.25rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 100%;")
                          ;table(style "width: 75%; border-collapse: collapse; margin: 0 auto;")
                            ;tr
                              ;th(colspan "3", style "text-align: center; padding: 10px; background: #f5f5f5; border: 1px solid #ddd;"): My Favorites
                            ==
                            ;tr
                              ;td(colspan "3", style "padding: 10px; border: 1px solid #ddd; text-align: center;")
                                ;form(method "POST", action "/apps/xchange/add-favorite", style "display: flex; flex-direction: column; gap: 10px; align-items: center;")
                                  ;div(style "display: flex; gap: 10px; align-items: center;")
                                    ;input(type "text", name "ship", placeholder "Enter ship name", pattern "^~[a-z-]+$", style "padding: 5px; border: 1px solid #ccc; border-radius: 4px; font-size: 1.25rem;");
                                    ;input(type "text", name "comment", placeholder "Comment (optional)", style "padding: 5px; border: 1px solid #ccc; border-radius: 4px; font-size: 1.25rem;");
                                    ;button(type "submit", style "padding: 5px 10px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1.25rem;"): Add
                                  ==
                                ==
                              ==
                            ==
                            ;tr
                              ;th(style "padding: 8px; border: 1px solid #ddd; text-align: left; font-size: 1.75rem;"): Ship
                              ;th(style "padding: 8px; border: 1px solid #ddd; text-align: left; font-size: 1.75rem;"): Comment  
                              ;th(style "padding: 8px; border: 1px solid #ddd; text-align: left; font-size: 1.75rem;"): Actions
                            ==
                            ;*  %+  turn  favorites-list
                              |=  f=[ship=@p comment=@t]
                              ;tr
                                ;td(style "padding: 8px; border: 1px solid #ddd; font-size: 1.25rem;"): {(trip (scot %p ship.f))}
                                ;td(style "padding: 8px; border: 1px solid #ddd; font-size: 1.25rem;")
                                  ;form(method "POST", action "/apps/xchange/edit-favorite", style "display: inline;")
                                    ;input(type "hidden", name "ship", value "{(trip (scot %p ship.f))}");
                                    ;input(type "text", name "comment", value "{(trip comment.f)}", pattern "^~[a-z-]+$", style "width: 100%; border: none; background: transparent; font-size: 1.25rem;");
                                    ;button(type "submit", style "padding: 3px 8px; background: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 0.75rem; margin-left: 5px;"): Save
                                  ==
                                ==
                                ;td(style "padding: 8px; border: 1px solid #ddd; font-size: 1rem;")
                                  ;form(method "POST", action "/apps/xchange/delete-favorite", style "display: inline;")
                                    ;input(type "hidden", name "ship", value "{(trip (scot %p ship.f))}");
                                    ;button(type "submit", style "padding: 3px 8px; background: #dc3545; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 0.875rem;"): Delete
                                  ==
                                ==
                              ==
                          ==
                        ==
                      ==
                    :: Right column - My Avoids
                    ;div(style "flex: 1; min-width: 0; display: flex; justify-content: center; padding: 20px 10px 0 10px;")
                              ;+  ?:  =(my-avoids ~)
                                ;div.table-div(style "background: white; padding: 1.25rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 100%;")
                                  ;table(style "width: 75%; border-collapse: collapse; margin: 0 auto;")
                                    ;tr
                                      ;th(colspan "4", style "text-align: center; padding: 10px; background: #f5f5f5; border: 1px solid #ddd;"): My Avoids
                                    ==
                                    ;tr
                                      ;td(colspan "4", style "padding: 10px; border: 1px solid #ddd; text-align: center;")
                                        ;form(method "POST", action "/apps/xchange/add-avoid", style "display: flex; flex-direction: column; gap: 10px; align-items: center;")
                                          ;div(style "display: flex; gap: 10px; align-items: center;")
                                            ;input(type "text", name "ship", placeholder "Enter ship name", style "padding: 5px; border: 1px solid #ccc; border-radius: 4px; font-size: 20px;");
                                            ;input(type "text", name "comment", placeholder "Comment (optional)", style "padding: 5px; border: 1px solid #ccc; border-radius: 4px; font-size: 20px;");
                                            ;button(type "submit", style "padding: 5px 10px; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 20px;"): Add
                                          ==
                                          ;div(style "display: flex; gap: 5px; align-items: center;")
                                            ;span(style "font-size: 20px; margin-right: 5px;"): Block:
                                            ;input(type "radio", name "block", value "%.y", id "block-yes", style "margin-right: 3px;");
                                            ;label(for "block-yes", style "margin-right: 10px;"): Yes
                                            ;input(type "radio", name "block", value "%.n", id "block-no", checked "checked", style "margin-right: 3px; font-size: 14px;");
                                            ;label(for "block-no", style "margin-right: 10px;"): No
                                          ==
                                        ==
                                      ==
                                    ==
                                    ;tr
                                      ;th(style "padding: 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Ship
                                      ;th(style "padding: 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Comment
                                      ;th(style "padding: 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Blocked
                                      ;th(style "padding: 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Actions
                                    ==
                                    ;tr
                                      ;td#empty-row(colspan "4", style "padding: 20px; text-align: center; border: 1px solid #ddd; font-size: 20px;")
                                        ;p: No Avoids
                                      ==
                                    ==
                                  ==
                                ==
                              ::
                              =/  avoids-list  ~(tap by my-avoids)
                              ;div.table-div(style "background: white; padding: 1.25rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); width: 100%;")
                                ;table(style "width: 75%; border-collapse: collapse; margin: 0 auto;")
                                  ;tr
                                    ;th(colspan "4", style "text-align: center; padding: 10px; background: #f5f5f5; border: 1px solid #ddd;"): My Avoids
                                  ==
                                  ;tr
                                    ;td(colspan "4", style "padding: 10px; border: 1px solid #ddd; text-align: center;")
                                      ;form(method "POST", action "/apps/xchange/add-avoid", style "display: flex; flex-direction: column; gap: 10px; align-items: center;")
                                        ;div(style "display: flex; gap: 10px; align-items: center;")
                                          ;input(type "text", name "ship", placeholder "Enter ship name", style "padding: 5px; font-size: 20px; border: 1px solid #ccc; border-radius: 4px;");
                                          ;input(type "text", name "comment", placeholder "Comment (optional)", style "padding: 5px; font-size: 20px; border: 1px solid #ccc; border-radius: 4px;");
                                          ;button(type "submit", style "padding: 5px 10px; background: #007bff; font-size: 20px; color: white; border: none; border-radius: 4px; cursor: pointer;"): Add
                                        ==
                                      ;div(style "display: flex; gap: 5px; align-items: center;")
                                          ;span(style "margin-right: 5px; font-size: 20px;"): Block:
                                          ;input(type "radio", name "block", value "%.y", id "block-yes2", style "margin-right: 3px; font-size: 20px;");
                                          ;label(for "block-yes2", style "margin-right: 10px; font-size: 20px;"): Yes
                                          ;input(type "radio", name "block", value "%.n", id "block-no2", checked "checked", style "margin-right: 3px;");
                                          ;label(for "block-no2", style "margin-right: 10px; font-size: 20px;"): No
                                        ==
                                      ==
                                    ==
                                  ==
                                  ;tr
                                    ;th(style "padding: 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Ship
                                    ;th(style "padding: 8px 20px 8px 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Comment 
                                    ;th(style "padding: 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Blocked
                                    ;th(style "padding: 8px; border: 1px solid #ddd; font-size: 28px; text-align: left;"): Actions
                                  ==
                                  ;*  %+  turn  avoids-list
                                    |=  a=[ship=@p avoid=my-avoid]
                                    ;tr
                                      ;td(style "padding: 8px; border: 1px solid #ddd; font-size: 20px;"): {(trip (scot %p ship.a))}
                                      ;td(style "padding: 8px; border: 1px solid #ddd; font-size: 20px;")
                                        ;form(method "POST", action "/apps/xchange/edit-avoid", style "display: inline margin-left: 10px;")
                                          ;input(type "hidden", name "ship", value "{(trip (scot %p ship.a))}");
                                          ;input(type "text", name "comment", value "{(trip comment.avoid.a)}", style "width: 100%; border: none; background: transparent; font-size: 20px;");
                                          ;input(type "hidden", name "block", value "{(trip (scot %f block.avoid.a))}");
                                          ;button(type "submit", style "padding: 3px 8px; background: #28a745; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 12px; margin-left: 5px;"): Save
                                        ==
                                      ==
                                      ;td(style "padding: 8px; border: 1px solid #ddd; font-size: 20px;"): {(trip (scot %f block.avoid.a))}
                                      ;td(style "padding: 8px; border: 1px solid #ddd; font-size: 16px;")
                                        ;form(method "POST", action "/apps/xchange/delete-avoid", style "display: inline; margin-left: 10px;")
                                          ;input(type "hidden", name "ship", value "{(trip (scot %p ship.a))}");
                                          ;button(type "submit", style "padding: 3px 8px; background: #dc3545; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 14px;"): Delete
                                        ==
                                        ;form(method "POST", action "/apps/xchange/edit-avoid", style "display: inline; margin-left: 10px;")
                                          ;input(type "hidden", name "ship", value "{(trip (scot %p ship.a))}");
                                          ;input(type "hidden", name "comment", value "{(trip comment.avoid.a)}");
                                          ;+  ?:  =(block.avoid.a %.y)
                                            ;input(type "hidden", name "block", value "%.n");
                                          ::
                                          ;input(type "hidden", name "block", value "%.y");
                                          ;+  ?:  =(block.avoid.a %.y)
                                            ;button(type "submit", style "padding: 3px 8px; background: #ffc107; color: black; border: none; border-radius: 3px; cursor: pointer; font-size: 14px;"): Unblock
                                          ::
                                          ;button(type "submit", style "padding: 3px 8px; background: #dc3545; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 14px;"): Block
                                        ==
                                      ==
                                    ==
                                ==
                              ==
                            ==
                            ==
                            ==
                          ==
                      ==::close body
                    ==:: close html
          =/  =response-header:http
            :-  200
            :~  ['content-type' 'text/html; charset=utf-8']
            ==
          :~
            [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
            [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
            [%give %kick [/http-response/[p.req]]~ ~]
          ==
    ::
    ++  post-pals-webpage
        |=  [req=(pair @ta inbound-request:eyre) message=@t]
        ^-  (list card)
        ::=/  encoded-message  (scow %t message)  :: Simple encoding, or just use the message directly if it's safe
        =/  =response-header:http
          :-  303
          :~  ['Location' '/apps/xchange/pals']
          ==
        :~
          [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
          [%give %fact [/http-response/[p.req]]~ %http-response-data !>(~)]
          [%give %kick [/http-response/[p.req]]~ ~]
        ==
    ::
     ::
    ++  render-pals-page
        |=  [req=(pair @ta inbound-request:eyre) our=@p eny=@t my-favorites=(map ship=@p comment=@t) my-avoids=(map ship=@p my-avoid) message=@t]
        ^-  (list card)
          =/  =response-header:http
                      :-  301
                      :~  ['Location' '/apps/xchange/pals']
                      ==
                    :~
                      [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                      [%give %kick [/http-response/[p.req]]~ ~]
                    ==
    ::
    ++  post-fav-state
        |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t my-favorites=(map ship=@p comment=@t) my-avoids=(map ship=@p my-avoid) message-pals=@t]
        ^-  state=_state
        =/  data=octs  +.body.request.q.req
        =/  text-data  (crip (trip +.data))
        =/  parsedata  (need (rush text-data yquy:de-purl:html))
        =/  new-fav-ship  (snag 0 parsedata)
        =/  ship-cord  (crip (trip +.new-fav-ship))
        =/  maybe-ship  (slaw %p ship-cord)
        ?~  maybe-ship
          state(message-pals 'Invalid ship name entered')
        =/  new-ship2ad  `@p`u.maybe-ship
        =/  new-fav-com  (snag 1 parsedata)
        ?:  (~(has by my-avoids) new-ship2ad)
          state(message-pals 'Ship is on your avoid list')
        =/  newpair  [new-ship2ad +.new-fav-com]
        =/  new-fav  (~(put by my-favorites) newpair)
        =/  success-message  'Favorite added successfully'
        state(my-favorites new-fav, message-pals success-message)
::
   ++  post-avoid-state
        |=  [req=(pair @ta inbound-request:eyre) now=@da our=@p eny=@t my-favorites=(map ship=@p comment=@t) my-avoids=(map ship=@p my-avoid) message-pals=@t]
        ^-  state=_state
        =/  data=octs  +.body.request.q.req
        =/  text-data  (crip (trip +.data))
        =/  parsedata  (need (rush text-data yquy:de-purl:html))
        =/  new-avoid-ship  (snag 0 parsedata)
        =/  ship-cord  (crip (trip +.new-avoid-ship))
        =/  maybe-ship  (slaw %p ship-cord)
        ?~  maybe-ship
          state(message-pals 'Invalid ship name entered')
        =/  new-ship2ad  `@p`(slav %p (crip (trip +.new-avoid-ship)))
        =/  new-avoid-com  (snag 1 parsedata)
        ?:  (~(has by my-favorites) new-ship2ad)
          state(message-pals 'Ship is on your favorite list')
        =/  raw-avoid-block  (snag 2 parsedata) :: parse logical as a cord
        =/  new-avoid-block  ?:  =(+.raw-avoid-block '%.y')  %.y  %.n  :: Compare & convert to @f 
        =/  newpair  [new-ship2ad [+.new-avoid-com new-avoid-block]]
        =/  new-avoids  (~(put by my-avoids) newpair)
        =/  success-message  'Avoid added successfully'
        state(my-avoids new-avoids, message-pals success-message)
       :: 
    ++  validate-add-favorite
        |=  [ship=@p my-avoids=(map ship=@p my-avoid) my-favorites=(map ship=@p comment=@t)]
        ^-  ?
        ::  Check if ship is already in avoids
        ?:  (~(has by my-avoids) ship)  %.n
        ::  Check if ship is already in favorites
        ?:  (~(has by my-favorites) ship)  %.n
        %.y
      ::
      ++  validate-add-avoid
          |=  [ship=@p my-avoids=(map ship=@p my-avoid) my-favorites=(map ship=@p comment=@t)]
          ^-  ?
          ::  Check if ship is already in favorites
          ?:  (~(has by my-favorites) ship)  %.n
          ::  Check if ship is already in avoids
          ?:  (~(has by my-avoids) ship)  %.n
          %.y
::
    ++  edit-favorite-state  
      |=  [req=(pair @ta inbound-request:eyre) my-favorites=(map ship=@p comment=@t) message-pals=@t]
      ^-  state=_state
      =/  data=octs  +.body.request.q.req
      =/  text-data  (crip (trip +.data))
      =/  parsedata  (need (rush text-data yquy:de-purl:html))
      =/  ship-to-edit  (snag 0 parsedata)
      =/  new-comment  (snag 1 parsedata)
      =/  ship-cord  (crip (trip +.ship-to-edit))
      =/  maybe-ship  (slaw %p ship-cord)
      ?~  maybe-ship
        state(message-pals 'Invalid ship name entered')
      =/  ship-edit  `@p`u.maybe-ship
      =/  new-favorites  (~(put by my-favorites) ship-edit +.new-comment)
      =/  success-message  'Favorite updated successfully'
         state(my-favorites new-favorites, message-pals success-message)
::
  ++  delete-favorite-state
    |=  [req=(pair @ta inbound-request:eyre) my-favorites=(map ship=@p comment=@t) message-pals=@t]
    ^-  state=_state
    =/  data=octs  +.body.request.q.req
    =/  text-data  (crip (trip +.data))
    =/  parsedata  (need (rush text-data yquy:de-purl:html))
    =/  ship-to-delete  (snag 0 parsedata)
    =/  ship-cord  (crip (trip +.ship-to-delete))
    =/  maybe-ship  (slaw %p ship-cord)
    ?~  maybe-ship
      state(message-pals 'Invalid ship name entered')
    =/  ship-to-remove  `@p`u.maybe-ship
    =/  new-favorites  (~(del by my-favorites) ship-to-remove)
    =/  success-message  'Favorite deleted successfully'
    state(my-favorites new-favorites, message-pals success-message)
::
  ++  delete-avoid-state
    |=  [req=(pair @ta inbound-request:eyre) my-avoids=(map ship=@p my-avoid) message-pals=@t]
    ^-  state=_state
    =/  data=octs  +.body.request.q.req
    =/  text-data  (crip (trip +.data))
    =/  parsedata  (need (rush text-data yquy:de-purl:html))
    =/  ship-to-delete  (snag 0 parsedata)
    =/  ship-cord  (crip (trip +.ship-to-delete))
    =/  maybe-ship  (slaw %p ship-cord)
    ?~  maybe-ship
      state(message-pals 'Invalid ship name')
    =/  ship-to-remove  `@p`u.maybe-ship
    =/  new-avoids  (~(del by my-avoids) ship-to-remove)
    =/  success-message  'Avoid deleted successfully'
      state(my-avoids new-avoids, message-pals success-message)
::
   ++  edit-avoid-state  
      |=  [req=(pair @ta inbound-request:eyre) my-avoids=(map ship=@p my-avoid) message-pals=@t]
      ^-  state=_state
      =/  data=octs  +.body.request.q.req
      =/  text-data  (crip (trip +.data))
      =/  parsedata  (need (rush text-data yquy:de-purl:html))
      =/  ship-to-edit  (snag 0 parsedata)
      =/  new-comment  (snag 1 parsedata)
      =/  raw-avoid-block  (snag 2 parsedata) :: parse logical as a cord
      =/  new-avoid-block  ?:  =(+.raw-avoid-block '%.y')  %.y  %.n  :: Compare & convert to @f 
      =/  ship-cord  (crip (trip +.ship-to-edit))
      =/  maybe-ship  (slaw %p ship-cord)
      ?~  maybe-ship
          state(message-pals 'Invalid ship name entered')
      =/  ship-edit  `@p`u.maybe-ship
      =/  new-avoids  (~(put by my-avoids) ship-edit [+.new-comment new-avoid-block])
      =/  success-message  'Avoid updated successfully'
         state(my-avoids new-avoids, message-pals success-message)
::
    ++  text-to-binary
        |=  text=@t
        ^-  @ub
        ::  Convert cord (text) to binary atom by taking the raw bytes
        `@ub`text
    ::
    ++  serve-sigil
  |=  [req=(pair @ta inbound-request:eyre) =bowl:gall eny=@]
  ^-  (list card)
  =/  purl  (rash url.request.q.req ;~(plug apat:de-purl:html yque:de-purl:html))
  =/  query-params  +.purl
  =/  args  
    %-  ~(gas by *(map @t @t))
    ?~  query-params  ~
    query-params
  
  ::  Extract parameters with defaults
  =/  ship-param=@t  (~(gut by args) 'p' (scot %p our.bowl))
  =/  size-param=@t  (~(gut by args) 'size' '128')
  =/  fg-param=@t    (~(gut by args) 'fg' 'white')
  =/  bg-param=@t    (~(gut by args) 'bg' 'black')
  =/  margin=?       !(~(has by args) 'no-margin')
  =/  icon=?         (~(has by args) 'icon')
  
  ::  Generate sigil SVG
  =/  sigil-svg=manx
    %.  (slav %p ship-param)
    %_  sigil
      size    (slav %ud size-param)
      fg      (trip fg-param)
      bg      (trip bg-param)
      margin  margin
      icon    icon
    ==
  
  ::  Convert manx to octs
  =/  svg-tape=tape  (en-xml:html sigil-svg)
  =/  svg-content=octs  (as-octs:mimes:html (crip svg-tape))
  
  ::  Create HTTP response
  =/  =response-header:http
    :-  200
    :~  ['Content-Type' 'image/svg+xml']
        ['Cache-Control' 'public, max-age=2592000, immutable']
    ==
  
  :~  [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
      [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`svg-content)]
      [%give %kick [/http-response/[p.req]]~ ~]
  ==
    ::
  ++  get-settings
  |=  $:  req=(pair @ta inbound-request:eyre)
          our=@p 
          maxpic-size=@ud 
          maxad-timeout=@dr 
          maxapp-size=@ud 
          message-setting=@t
          alerts=(map alert-id=@t alert)
          alert-results=(map ad-id=@t alert-result)
          mylistings1=(map id=@t advert1)
          listings1=(map id=@t advert1)
      ==
  ^-  (list card)
              =/  alerts-count  ~(wyt by alerts)
              =/  alert-results-count  ~(wyt by alert-results)
              =/  mylistings1-count  ~(wyt by mylistings1)
              =/  mylistings-count  ~(wyt by mylistings)
              =/  listings1-count  ~(wyt by listings1)
              =/  alerts-size  (met 3 (jam alerts))
              =/  alert-results-size  (met 3 (jam alert-results))
              =/  mylistings1-size  (met 3 (jam mylistings1))
              =/  mylistings-size  (met 3 (jam mylistings))
              =/  listings1-size  (met 3 (jam listings1))
              =/  listings-size  (met 3 (jam listings))
              =/  app-memory-usage  (memory-estimate our)
              =/  memory-display  (format-memory-size app-memory-usage)
              =/  alerts-mb  (div alerts-size 1.048.576)
              =/  alert-results-mb  (div alert-results-size 1.048.576)
              =/  alert-results-mem  (format-memory-size alert-results-size)
              =/  mylistings1-mb  (div mylistings1-size 1.048.576)
              =/  mylistings-mb  (div mylistings-size 1.048.576)
              =/  mylistings1-mem  (format-memory-size mylistings1-size)
              =/  listings1-mb  (div listings1-size 1.048.576)
              =/  listings1-mem  (format-memory-size listings1-size)
              =/  listings-mb  (div listings-size 1.048.576)
              =/  body
                %-  as-octs:mimes:html
                %-  crip
                %-  en-xml:html
                ;html
                    ;head
                      ;title:"Xchange"
                      ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                      ;meta(charset "utf-8");
                      ;meta(name "viewport", content "width=device-width, initial-scale=1");
                      ;style: {style}
                    ==::closes head
                    ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                ::
                ;div.main-content
                   ;div.left-bar
                    ;ul
                        ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                        ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==
                         ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                        ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                      ::Message-settings display
                      ;+  ?:  =(message-settings '')
                        ;div;
                        ::
                        =/  search-result  (find "Successfully" (trip message-settings))
                        =/  contains-success  ?=(^ search-result)
                        =/  bg-color  ?:(contains-success "#d4edda" "#f8d7da")
                        =/  border-color  ?:(contains-success "#c3e6cb" "#f5c6cb")
                        =/  text-color  ?:(contains-success "#155724" "#721c24")
                        ;div(style "display: flex; justify-content: center; margin: 20px 0;")
                          ;div(style "width: 75%; padding: 15px; text-align: center; background: {bg-color}; border: 1px solid {border-color}; border-radius: 4px; color: {text-color}; font-size: 18px;")
                            ;p: {(trip message-settings)}
                          ==
                        ==
                        ::
                        ;div.table-div-ads
                                ;form(method "post", action "/apps/xchange/settings")
                                  ;table.myad-form-table
                                    ::Optional: Add a header row
                                    ;tr
                                      ;th: Setting
                                      ;th: Value  
                                      ;th: Valid Range
                                    ==  ::closes tr.header-row
                                    
                                    ;tr
                                      ;td: Max Upload Picture Size (MB)
                                      ;td
                                        ;div.myad-input-cell
                                        ;input(type "text", name "maxpic-size", value "{(scow %ud maxpic-size)}", style "font-size: 18px;"); 
                                        ==  ::closes div.myad-input-cell
                                      ==  ::closes td
                                      ;td.range-column: 1-3 MB
                                    ==  ::closes tr
                                    
                                    ;tr
                                      ;td: Max Ad Time Duration (days)
                                      ;td
                                        ;div.myad-input-cell
                                          ;input(type "text", name "maxad-timeout", value "{(scow %dr maxad-timeout)}", style "font-size: 18px;"); 
                                        ==  ::closes div.myad-input-cell
                                      ==  ::closes td
                                      ;td.range-column: 1-365 days
                                    ==  ::closes tr
                                    
                                  ;tr
                                      ;td: App Max Size (MB)
                                      ;td
                                        ;div.myad-input-cell
                                        ;input(type "text", name "app-max-size", value "{(scow %ud maxapp-size)}", style "font-size: 18px;"); 
                                        ==  ::closes div.myad-input-cell
                                      ==  ::closes td
                                      ;td.range-column: Estimated Xchange App Size: {memory-display}
                                    ==  ::closes tr
        
                                  ;tr
                                      ;td(colspan "3", style "text-align: center;")
                                        ;button(type "submit", class "submit-button"): Update Settings
                                      ==
                                    ==
                              ==  ::closes table.myad-form-table
                              ==  ::closes form
                              ;div.spacer
                                ;br;
                                ;br;
                              ==::closes .spacer
                              ;table.myad-form-table
                                    ::Optional: Add a header row
                                    ;tr
                                      ;th: Map
                                      ;th: Count 
                                      ;th: Memory Size
                                    ==  ::closes tr.header-row
                                    ;tr
                                      ;td: Total Ads
                                      ;td: {(trip (scot %ud listings1-count))}
                                      ::;td: {(trip (scot %ud listings1-mb))}
                                      ;td:  {listings1-mem}
                                    ==
                                    ;tr
                                      ;td: My Ads
                                      ;td: {(trip (scot %ud mylistings1-count))}
                                      ;td: {mylistings1-mem}
                                    ==
                                     ;tr
                                      ;td: Ads Matched to Alerts
                                      ;td: {(trip (scot %ud alert-results-count))}
                                      ;td: {alert-results-mem}
                                    ==
                             ==
                        ==  ::closes div.table-div-ads
                        
                      ==
                  ==  ::closes body
                ==  ::closes html
                =/  =response-header:http
                    :-  200
                    :~  ['content-type' 'text/html; charset=utf-8']
                    ==
                  :~
                    [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                    [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                    [%give %kick [/http-response/[p.req]]~ ~]
                  ==
   
            ::
           ++  update-settings-state
                  |=  [req=(pair @ta inbound-request:eyre) our=@p maxpic-size=@ud maxad-timeout=@dr maxapp-size=@ud message-settings=@t]
                  ::~&  [%req req]
                  =/  data=octs  +.body.request.q.req
                  ::~&  [%data data]
                  =/  text-data  (crip (trip +.data))
                  ::~&  [%text-data text-data]
                  =/  parsedata  (need (rush text-data yquy:de-purl:html))
                  ::~&  [%parsedata parsedata]
                  =/  maxpic-cord  (snag 0 parsedata)
                  =/  maybe-maxpic-size  (slaw %ud +.maxpic-cord)
                    ?~  maybe-maxpic-size
                        =/  error-body  'Error: Invalid Max Picture Size needs to be an integer'       
                    state(message-settings error-body)
                  =/  new-maxpic-size  `@ud`u.maybe-maxpic-size 
                    ?:  |((gth new-maxpic-size 3) (lth new-maxpic-size 0))
                    =/  error-body  'Error: Max Picture Size exceeds 0-3MB limit'       
                    state(message-settings error-body)
                    ::~&  [%new-maxpic-size new-maxpic-size]
                  =/  maxad-days-cord  (snag 1 parsedata)
                  =/  maybe-max-days  (slaw %dr +.maxad-days-cord)
                    ?~  maybe-max-days
                    =/  error-body  'Error: Invalid Max days. needs to be in the form of ~d#'
                    state(message-settings error-body)
                  =/  new-max-days  `@dr`u.maybe-max-days
                  ?:  (lth new-max-days 1)
                  =/  error-body  'Error: Max Days can not be less than 1'
                  state(message-settings error-body)
                  ::~&  [%new-max-days `@dr`new-max-days]                  
                  =/  maxapp-cord  (snag 2 parsedata)
                  ::~&  [%maxapp-cord maxapp-cord]
                  =/  maybe-maxapp-size  (slaw %ud +.maxapp-cord)
                    ?~  maybe-maxapp-size
                    =/  error-body  'Error: Invalid Max App Size needs to be an integer'
                    state(message-settings error-body)
                  ::~&  [%new-maxapp-size new-maxapp-size]
                   =/  new-maxapp-size  `@ud`u.maybe-maxapp-size
                   ?:  |((gth new-maxapp-size 6.000) (lth new-maxapp-size 1))
                    =/  error-body  'Error: Max App Size exceeds 0-6000MB limit'
                    state(message-settings error-body)
                  =/  success-message  'Setting Update Successfully'

                  state(maxpic-size new-maxpic-size, maxad-timeout new-max-days, maxapp-size new-maxapp-size, message-settings success-message)
                ::
            ++  post-settings-webpage
              |=  [req=(pair @ta inbound-request:eyre) our=@p maxpic-size=@ud maxad-timeout=@dr maxapp-size=@ud]
              ^-  (list card)
              =/  =response-header:http
                  :-  301
                  :~  ['Location' '/apps/xchange/settings']
                  ==
                :~
                  [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                  [%give %kick [/http-response/[p.req]]~ ~]
                ==
            ::    sorting arms
    ++  sort-listings
      |=  [listings=(list [id=@t advert1]) column=@t ascending=?]
      ^-  (list [id=@t advert1])
      ?+  column  listings
        %title
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          ?:  ascending
            (aor ad-title.+.a ad-title.+.b)
          (aor ad-title.+.b ad-title.+.a)
        
        %date
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          ?:  ascending
            (lth when.+.a when.+.b)
          (gth when.+.a when.+.b)
        
        %type
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          ?:  ascending
            (aor type.+.a type.+.b)
          (aor type.+.b type.+.a)
        
        %price
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          =/  price-a  ?~(price.+.a '0' u.price.+.a)
          =/  price-b  ?~(price.+.b '0' u.price.+.b)
          ?:  ascending
            (aor price-a price-b)
          (aor price-b price-a)
         %timezone
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          =/  timezone-a  ?~(timezone.+.a '0' u.timezone.+.a)
          =/  timezone-b  ?~(timezone.+.b '0' u.timezone.+.b)
          ?:  ascending
            (aor timezone-a timezone-b)
          (aor timezone-b timezone-a)
        %contact
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          ?:  ascending
            (aor contact.+.a contact.+.b)
          (aor contact.+.b contact.+.a)
        
        %ship
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          ?:  ascending
            (aor ship.+.a ship.+.b)
          (aor ship.+.b ship.+.a)

        %body
          %+  sort  listings
          |=  [a=[id=@t advert1] b=[id=@t advert1]]
          ?:  ascending
            (aor body.+.a body.+.b)
          (aor body.+.b body.+.a)
      ==
    ::
   ++  handle-sort
      |=  [req=(pair @ta inbound-request:eyre) current-sort=[column=@t ascending=?]]
      ^-  [column=@t ascending=?]
      ?~  body.request.q.req
        current-sort
      =/  body-text  q.u.body.request.q.req
      =/  form-data  (rush body-text yquy:de-purl:html)
      ?~  form-data
        current-sort
      =/  params-list  u.form-data
      =/  column-param
        %+  roll  params-list
        |=  [[k=@t v=@t] acc=(unit @t)]
        ?^  acc  acc
        ?:  =(k 'column')  `v
        ~
      ?~  column-param
        current-sort
      =/  new-column  u.column-param
      =/  new-ascending
        ?:  =(new-column column.current-sort)
          !ascending.current-sort
        %.y
      [column=new-column ascending=new-ascending]
    ::
    ++  memory-estimate
        |=  our=@p
        ^-  @ud
        =/  state-size=@ud  (met 3 (jam state))
       (mul state-size 5)

    ++  format-memory-size
        |=  size=@ud
        ^-  tape
        =/  gb=@ud  (div size 1.073.741.824)
        =/  mb=@ud  (div size 1.048.576)
        =/  kb=@ud  (div size 1.024)
        ?:  (gth gb 0)
          =/  mb-remainder=@ud  (sub mb (mul gb 1.024))
          "{(scow %ud gb)}.{(scow %ud mb-remainder)} GB"
        ?:  (gth mb 0)
          =/  kb-remainder=@ud  (sub kb (mul mb 1.024))
          "{(scow %ud mb)}.{(scow %ud kb-remainder)} MB"
        ?:  (gth kb 0)
          "{(scow %ud kb)} KB"
        "{(scow %ud size)} bytes"
   ++  ad-manager
    |=  [now=@da our=@p listings1=(map id=@t advert1) alert-results=(map ad-id=@t alert-result) maxad-timeout=@dr maxapp-size=@ud]
    ^-  [(map id=@t advert1) (map ad-id=@t alert-result)]
    =/  timeout  `@da`(sub now maxad-timeout)
    =/  current-memory  (memory-estimate our)
    =/  maxapp-size-byte  (mul maxapp-size (mul 1.024 1.024))
    =/  cleaned-listings
      %-  malt
      %+  turn
        %+  skim
          ~(tap by listings1)
          |=  [key=@t value=advert1]
          (gth when.value timeout)
        |=  [key=@t value=advert1]
        [key value]
    ::  Filter expired alert-results
    =/  cleaned-alert-results
      %-  malt
      %+  turn
        %+  skim
          ~(tap by alert-results)
          |=  [key=@t value=alert-result]
          (gth when.value timeout)
        |=  [key=@t value=alert-result]
        [key value]
    ::  Return both cleaned maps
    [cleaned-listings cleaned-alert-results]
::
   ++  remove-oldest-until-size
    |=  [our=@p current-listings=(map id=@t advert1) current-alert-results=(map ad-id=@t alert-result) maxapp-size=@ud]
    ^-  (map @t advert1)
    =/  maxapp-size-byte  (mul maxapp-size (mul 1.024 1.024))
    ::  Update state temporarily and check memory
    =.  listings1.state  current-listings
    =.  alert-results.state  current-alert-results
    =/  current-memory  (memory-estimate our)
    ::  If memory is acceptable, return as-is
    ?:  (lte current-memory maxapp-size-byte)
      current-listings
    ::  Sort by date (oldest first)
    =/  sorted-by-date
      %+  sort
        ~(tap by current-listings)
        |=  [[key1=@t value1=advert1] [key2=@t value2=advert1]]
        (lth when.value1 when.value2)
    ::  Remove oldest ads until under size
    |-
    =.  listings1.state  current-listings
    =.  alert-results.state  current-alert-results
    =/  current-memory  (memory-estimate our)
    ?:  (lte current-memory maxapp-size-byte)
      current-listings
    ?~  sorted-by-date
      current-listings
    =/  [oldest-key=@t oldest-ad=advert1]  i.sorted-by-date
    =/  remaining-listings  (~(del by current-listings) oldest-key)
    $(sorted-by-date t.sorted-by-date, current-listings remaining-listings)
    ::
    ++  get-subscriptions
        |=  $:  req=(pair @ta inbound-request:eyre)
                our=@p
                bowl=bowl:gall
                alerts=(map alert-id=@t alert)
                alert-results=(map ad-id=@t alert-result)
                mylistings1=(map id=@t advert1)
                listings1=(map id=@t advert1)
        ==
        ^-  (list card)
          =/  alerts-count  ~(wyt by alerts)
          =/  alert-results-count  ~(wyt by alert-results)
          =/  mylistings1-count  ~(wyt by mylistings1)
          =/  mylistings-count  ~(wyt by mylistings)
          =/  listings1-count  ~(wyt by listings1)
          =/  alerts-size  (met 3 (jam alerts))
         =/  incoming-subs=(list [=wire =ship =path])
          %+  turn  ~(tap by sup.bowl)
          |=  [=duct =ship =path]
          [/incoming ship path]     
        =/  outgoing-subs=(list [=wire =ship =path])
          %+  turn  ~(tap by wex.bowl)
          |=  [[=wire =ship name=term] [acked=? =path]]
          [wire ship path]
        ::~&  [%wbowl wex.bowl]
        =/  body
        %-  as-octs:mimes:html
        %-  crip
        %-  en-xml:html
        ;html
              ;head
                ;title:"Xchange"
                ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                ;meta(charset "utf-8");
                ;meta(name "viewport", content "width=device-width, initial-scale=1");
                ;style: {style}
              ==  :: closes `;head`
              ;body
                    ;div(class "header-wrapper")
                      ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                      ;div.search-bar
                          ;form(method "get", action "/apps/xchange/search", class "search-form")
                            ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                            ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                          ==                                   :: Closes form
                        ==   
                      ;div.ship-box                    
                            ::;p: 
                              ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                              ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                
                              ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                    ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                          ==                             
                      == ::closes header-wrapper
                     ;div.spacer
                      ;br;
                      ;br;
                    ==::closes .spacer
                ::
                ;div.main-content
                   ;div.left-bar
                    ;ul
                        ;li
                          ;a(href "/apps/xchange"): Home
                        ==
                        ;li
                          ;a(href "/apps/xchange/alert"): Alerts
                        ==
                        ;li
                          ;a(href "/apps/xchange/postad"): Post an Ad
                        ==
                        ;li
                          ;a(href "/apps/xchange/pals"): Pals
                        ==
                         ;li
                          ;a(href "/apps/xchange/subscriptions"): Subscriptions
                        ==
                      ==
                  ==::closes left-bar
                      ;div(class "subscriptions-container")
                          :: Left column - Incoming Subscriptions
                          ;div(class "subscription-column")
                            ;+  ?:  =(incoming-subs ~)
                                  ;div(class "subscription-table-wrapper")
                                    ;table(class "subscription-table")
                                    ;tr
                                      ;th(colspan "2", class "subscription-header subscription-header-main"): Incoming Subscriptions
                                    ==
                                    ;tr
                                      ;th(colspan "2", class "subscription-header subscription-header-sub"): Other ships subscribing to your ship's data
                                    ==
                                    ;tr
                                      ;th(class "subscription-th"): Ship
                                      ;th(class "subscription-th"): Path
                                    ==
                                  ;tr
                                  ;td#empty-row(colspan "2", class "subscription-empty")
                                    ;p: No Incoming Subscriptions
                                  == :: closes ;td (empty message cell)
                              == :: closes ;tr (empty row)
                          == :: closes ;table (empty case table)
                        == :: closes ;div.subscription-table-wrapper (empty case)
                          ;div(class "subscription-table-wrapper")
                              ;table(class "subscription-table")
                                  ;tr
                                    ;th(colspan "2", class "subscription-header"): Incoming Subscriptions
                                  ==
                                  ;tr
                                    ;th(colspan "2", class "subscription-header subscription-header-sub"): Other ships subscribing to your ship's data
                                  ==
                                  ;tr
                                    ;th(class "subscription-th"): Ship
                                     ;th(class "subscription-th"): Path
                                  == :: closes ;tr (column headers)
                                ;*  %+  turn  incoming-subs
                                  |=  [=wire =ship =path]
                                    ;tr
                                      ;td(class "subscription-td"): {(trip (scot %p ship))}
                                      ;td(class "subscription-td subscription-td-wrap"): {(spud path)}
                                    == :: closes ;tr (data row)
                                ==  :: closes ;* (turn expression)
                            ==  :: closes ;table (populated case table)
                          ==  :: closes ;div.table-div (populated case)
                       ;div(class "subscription-column")
                        ;+  ?:  =(outgoing-subs ~)
                            ;div.table-div(class "subscription-table-wrapper")
                              ;table(class "subscription-table")
                                ;tr
                                  ;th(colspan "3", class "subscription-header"): Outgoing Subscriptions
                                ==
                                 ;tr
                                  ;td(colspan "3", class "subscription-header"): Your ship subscribing to other ships data
                                ==  
                                ;tr
                                  ;th(class "subscription-th"): Ship
                                  ;th(class "subscription-th"): Path
                                  ;th(class "subscription-th"): Wire
                                ==
                                ;tr
                                  ;td#empty-row(colspan "3", class "subscription-empty")
                                    ;p: No Outgoing Subscriptions
                                  == :: closes ;td (empty message cell)
                                == :: closes ;tr (empty row)
                              == :: closes ;table (empty case table)
                            == :: closes ;div.table-div (empty case)
                          ;div.table-div(class "subscription-table-wrapper")
                            ;table(class "subscription-table")
                              ;tr
                                ;th(colspan "3", class "subscription-header"): Outgoing Subscriptions
                               == 
                               ;tr
                                ;td(colspan "3", class "subscription-header"): Your ship subscribing to other ships data
                              ==  
                              ;tr
                                ;th(class "subscription-th"): Ship
                                ;th(class "subscription-th"): Path
                                ;th(class "subscription-th"): Wire
                              == :: closes ;tr (column headers)
                              ;*  %+  turn  outgoing-subs  
                                |=  [=wire =ship =path]
                                  ;tr
                                    ;td(class "subscription-td"): {(trip (scot %p ship))}
                                    ;td(class "subscription-td"): {(spud path)}
                                    ;td(class "subscription-td"): {(spud wire)}
                                  == :: closes ;tr (data row)
                              == :: closes ;* (turn expression)
                            == :: closes ;table
                          == :: closes ;div.table-div
                      == :: ?:  conditional
                    ==
                == :: closes body                    
            ==::closes html                       
                =/  =response-header:http
                :-  200
                :~  ['content-type' 'text/html; charset=utf-8']
                ==
                  :~
                      [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                      [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                      [%give %kick [/http-response/[p.req]]~ ~]
                  ==
                  ::
         ++  get-search
            |=  [req=(pair @ta inbound-request:eyre) search-term=[@t @t] our=@p alerts=(map @t alert) listings1=(map @t advert1) my-avoids=(map ship=@p my-avoid) my-favorites=(map ship=@p comment=@t) sort-state=[column=@t ascending=?]]
            ^-  (list card)
            =/  active-listings-list  %+  skim  ~(tap by listings1.state)
              |=  a=[id=@t [ad-title=@t when=@da type=@t price=(unit @t) timezone=(unit @t) contact=@t ship=@p body=@t active=? image1=(unit image-info1) image2=(unit image-info2)]]
              =/  should-block
              ?~  avoid-entry=(~(get by my-avoids.state) ship.a)
                %.n
              block.u.avoid-entry
              ?:  should-block
                %.n
                =(%.y active.a)
            =/  active-listings  `(map @t advert1)`(malt active-listings-list)
            =/  search-listings  (search-matches [+.search-term active-listings])
            ::~&  [%search-term search-term]
            =/  body
                  %-  as-octs:mimes:html
                  %-  crip
                  %-  en-xml:html
                  ;html
                        ;head
                          ;title:"Xchange"
                          ;link(rel "icon", type "image/x-icon", href "data:image/svg+xml,{favicon}");
                          ;meta(charset "utf-8");
                          ;meta(name "viewport", content "width=device-width, initial-scale=1");
                          ;style: {style}
                        ==  :: closes `;head`
                        ;body
                            ;div(class "header-wrapper")
                            ;img(src "/apps/xchange/img/xchange-logo.png", alt "Xchange Logo", class "header-logo");
                            ;div.search-bar
                                ;form(method "get", action "/apps/xchange/search", class "search-form")
                                  ;input(type "text", name "q", placeholder "Search ...", style "padding: 8px 40px 8px 12px; border: 1px solid #ccc; border-radius: 25px; font-size: 24px; width: 800px; outline: none;");
                                  ;button(type "submit", style "position: absolute; right: 12px; background: none; border: none; cursor: pointer; font-size: 18px; color: #666; padding: 4px; display: flex; align-items: center; justify-content: center;"): 🔍
                                ==                                   :: Closes form
                              ==   
                            ;div.ship-box                    
                                  ::;p: 
                                    ;a(href "/apps/xchange/settings", class "ship-name-link"): {(trip `@t`(scot %p our))}
                                    ;img(src "/apps/xchange/sigil?p={(trip `@t`(scot %p our))}&size=175", alt "Your Sigil", class "ship-sigil"); 
                                      
                                    ;a(href "/apps/xchange/settings", style "color: #666; margin-left: 16px; font-size: 48px; text-decoration: none;"): ⚙️
                                          ::;p.ship-name: {(trip `@t`(scot %p our))}                         :: Closes div.ship-identity
                                ==                             
                            == ::closes header-wrapper
                          ;div.spacer
                            ;br;
                            ;br;
                          ==::closes .spacer
                          ;div.menu-bar
                          ;ul
                            ;li
                              ;a(href "/apps/xchange"): All
                            ==
                            ;li
                              ;a(href "/apps/xchange/type/services"): Services
                            ==
                            ;li
                              ;a(href "/apps/xchange/type/events"): Events
                            ==
                            ;li
                              ;a(href "/apps/xchange/type/jobs"): Jobs
                            ==
                            ;li
                              ;a(href "/apps/xchange/type/for_sale"): For-Sale
                            ==
                          ==
                        ==::closes menu-bar
                        ;div.main-content
                        ;div.left-bar
                          ;ul
                              ;li
                                ;a(href "/apps/xchange"): Home
                              ==
                              ;li
                                ;a(href "/apps/xchange/alert"): Alerts
                              ==
                              ;li
                                ;a(href "/apps/xchange/postad"): Post an Ad
                              ==                       
                              ;li
                                ;a(href "/apps/xchange/pals"): Pals
                              ==
                              ;li
                                ;a(href "/apps/xchange/subscriptions"): Subscriptions
                              ==
                            ==
                        ==::closes left-bar
                  ;div.table-wrapper
                    ;+  ?:  =(search-listings ~)
                      ;div.table-div
                              ;table
                                ;tr
                                  ;th: Thumbnail
                                  ;th: Title
                                  ;th: Date Posted
                                  ;th: Type
                                  ;th: Price
                                  ;th: Timezone
                                  ;th: Contact Information
                                  ;th: Ship
                                  ;th: Description
                                ==:: closes tr
                                 ;tr
                                    ;td#empty-row(colspan "9")
                                        ;p: No Matches
                                    ==
                                  ==
                                ==
                              ==
                            =/  search-listings-list  ~(tap by search-listings)
                        ;div.table-div
                            ;table
                              ;tr
                                ;th: Thumbnail
                                ;th: Title
                                ;th: Date Posted
                                ;th: Type
                                ;th: Price
                                ;th: Timezone
                                ;th: Contact Information
                                ;th: Ship
                                ;th: Description
                                ;th: Active
                                ;th;  
                              ==:: closes tr
                              ;*  %+  turn  search-listings-list
                                      |=  a=[id=@t ad-title=@t when=@da type=@t price=(unit @t) timezone=(unit @t) contact=@t ship=@p body=@t active=? image1=(unit image-info1) image2=(unit image-info2)]
                                        ;tr
                                          ;td(style "display: none;"): {(trip id.a)}
                                          ;td(style "text-align: center; vertical-align: middle;")
                                              ;+  ?~  image1.a
                                                ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                                              ?:  =(filename1.u.image1.a '')
                                                ;div(style "width: 80px; height: 80px; background-color: #ffffff; border: 0px solid #ddd; border-radius: 4px; display: inline-block;");
                                                ;img(src "/apps/xchange/img/listing/{(trip id.a)}/1", alt "Thumbnail", style "max-width: 80px; max-height: 80px; object-fit: cover; border-radius: 4px;");
                                              ==
                                                  ::;td(style "font-family: monospace; font-size: 10px; background-color: yellow; word-break: break-all; white-space: normal; max-width: 100px; overflow-wrap: break-word;"): {(trip id.a)}
                                          ;td
                                            ;a(href "/apps/xchange/view-ad?ad-id={(trip id.a)}"): {(trip ad-title.a)}
                                            ==
                                          ;td: {(trip (get-date when.a))}
                                          ;td: {(trip type.a)}
                                          ;td: {?:((gth (lent (trip +.price.a)) 60) (weld (scag 60 (trip +.price.a)) "...") (trip +.price.a))}
                                          ;td: {?:((gth (lent (trip +.timezone.a)) 60) (weld (scag 60 (trip +.timezone.a)) "...") (trip +.timezone.a))}
                                          ;td: {?:((gth (lent (trip contact.a)) 60) (weld (scag 60 (trip contact.a)) "...") (trip contact.a))}
                                          ;td: {(trip (scot %p ship.a))}
                                          ;td(style "word-wrap: break-word; overflow-wrap: break-word; max-width: 200px; white-space: normal;"): {?:((gth (lent (trip body.a)) 60) (weld (scag 60 (trip body.a)) "...") (trip body.a))}
                                        ==
                              ==::  closes table
                            ==:: closes tab-div
                          ==
                        ==
                      ==
                  ==
            =/  =response-header:http
              :-  200
              :~  ['content-type' 'text/html; charset=utf-8']
              ==
            :~  [%give %fact [/http-response/[p.req]]~ %http-response-header !>(response-header)]
                [%give %fact [/http-response/[p.req]]~ %http-response-data !>(`body)]
                [%give %kick [/http-response/[p.req]]~ ~]   
            ==
    ::
    ++  style
        ^~
        %-  trip
        '''
        body {
          font-family: Inter,-apple-system,BlinkMacSystemFont,Roboto,Helvetica,Arial,sans-serif,"Apple Color Emoji";
          font-size: 18px;
          display: flex;
          flex-direction: column;
          padding-top: 20px;
        }
        .column-sorter {
          background: none;
          border: none;
          cursor: pointer;
          font-size: 18px;
          text-decoration: underline;
          }
        .spacer {
              height: 60px;
              width: 100%;
            }

            textarea {
              font-size: 18px;
              width: 100%; 
              resize: vertical; 
              overflow: auto;
            }

            .identity-container {
              width: 100%;
              position: relative;
              display: flex;
              justify-content: center;
            }
            .header-wrapper {
                display: flex;
                flex-direction: row;
                justify-content: space-between; 
                align-items: center;
                position: relative;
                width: 95%;
                min-height: 100px;
                padding: 0 20px;
            }
            .header-wrapper1 {
              display: flex;
              }
             .header-logo {
                  height: 150px;
                  width: 150px;                      
                  object-fit: contain;
                  cursor: pointer;
                  transition: transform 0.2s ease;
                  flex-shrink: 0; 
              }
              .header-logo:hover {
                  transform: scale(1.05);
              }
              .search-bar {
                  flex: 1;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                }
                .search-form {
                  position: relative;
                  display: flex;
                  align-items: center;
                }
           .class-ship-box {
                display: flex;
                width: 200px;
                padding: 12px;
                font-size: 18px;
                border: 1px solid #ddd;
                border-radius: 4px;
                background-color: white;
                word-wrap: break-word;
                flex-shrink: 0;
              }
              .ship-box {
                width: 400px;
                padding: 12px;
                font-size: 18px;
                border: 1px solid #ddd;
                border-radius: 4px;
                background-color: white;
                word-wrap: break-word;
                flex-shrink: 0;
                display: flex;
                flex-direction: row;
                align-items: center;
                justify-content: center;
              }
              .ship-name-link {
                    color: inherit;
                    width: 150px;
                    text-decoration: none;
                    display: inline-block;  /* Needed for width to work on inline elements */
                    text-align: center;
                  }
            .file-input {
              font-size: 24px;
            }
             .file-remove {
              font-size: 24px;
              white-space: nowrap;
            }

        .header {
          font-weight: 200;
          font-size: 26px;
          margin: 0;
        }
        .menu-wrapper {
          width: 95%;
          display: flex;
          justify-content: space-between;
          padding: 20px;
          position: relative;
          z-index: 10;
        }
        .menu-bar {
          width: 95%;
          display: flex;
          justify-content: center;
          padding: 10px;
          margin: 0;
          position: relative;
          z-index: 10;
        }

        .menu-bar ul {
          list-style: none;
          margin: 0 auto;
          padding: 0;
          display: flex;
          gap: 40px;
          justify-content: center;
          max-width: 1000px;
          width: auto;
        }

        .menu-bar li {
          cursor: pointer;
          font-size: 24px;
          white-space: nowrap;
        }
        .menu-bar li:hover {
          text-decoration: underline;
          color: blue;
        }
        .main-content {
          display: flex;
          flex-direction: row;
        }
        .left-bar {
          display: flex;
          flex-direction: column;
          justify-content: flex-start;
          text-align: center;
          min-height: 100vh;
          width: 250px;
          }
          .left-bar ul {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 20px;
          }

          .left-bar li {
            font-size: 20px;
          }

          .left-bar li a {
            text-decoration: none;
            color: #333;
            display: block;
            padding: 12px 16px;
            border-radius: 4px;
            transition: background-color 0.2s;
          }

          .left-bar li a:hover {
            color: blue;
          }

        .post-ad-search-wrapper {
          position: absolute;
          font-size: 36px;
          top: 16px;
          left: 16px;
          display: flex;
          flex-direction: column;
          align-items: start;
          gap: 10px;
          z-index: 101;
        }
        form {
          display: flex;
          justify-content: center;
          flex-direction: column;
        }
        .list-item {
          display: flex;
          justify-content: start;
          flex-direction: row;
          margin: 16px 0px;
        }
        .submit-button {
          font-size: 18px;
          background-color: green;
          color: white;
          padding: 10px 20px;
          border: none;
          border-radius: 5px;
          cursor: pointer;
        }
        .delete-button {
          background-color: #333333;
          color: white;
          font-size: 20px;
          border: none;
          padding: 5px 20px;
          border-radius: 4px;
          cursor: pointer;
          margin-bottom: 10px;
        }
        .delete-button:hover {
        background-color: #A9A9A9;
        }
        .manage-button {
          background-color: #333333;
          color: white;
          font-size: 20px;
          border: none;
          padding: 5px 10px;
          border-radius: 4px;
          cursor: pointer;
          margin-top: 10px;
          margin-bottom: 10px;
        }
        .manage-button:hover {
        background-color: #A9A9A9;
        }
         .view-button {
          background-color: #333333;
          color: white;
          border: none;
          font-size: 20px;
          padding: 5px 10px;
          border-radius: 4px;
          cursor: pointer;
          margin-top: 10px;
          margin-bottom: 10px;
        }
        .view-button:hover {
        background-color: #A9A9A9;
        }
        .hide-button {
          background-color: rgb(0, 123, 255);
          color: white;
          font-size: 20px;
          border: none;
          padding: 5px 10px;
          border-radius: 4px;
          cursor: pointer;
        }

        .hide-button:hover {
          background-color: rgb(0, 190, 204);
        }
        .table-wrapper {
        flex: 1;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        padding: 20px;
        }
        .pals-wrapper {
        flex: 1;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        padding: 20px;
        }
        .table-main {
           width: 80%;
            margin-left: 0;
        }
        .table-div {
          display: flex;
          flex-direction: column;
          padding-bottom: 16px;
          font-size: 18px;
          overflow-x: auto;
          margin-left: 0;
        }
        .alert-wrapper {
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        align-items: center;
        width: 80%;
        }
         .table-div-alert-results {
          display: flex;
          flex-direction: column;
          padding-bottom: 16px;
          font-size: 18px;
          overflow-x: auto;
          align-items: center;
          width: 100%;
          justify-content: flex-start;
          text-align: center
        }

        .table-div-received {
          padding-bottom: 32px;
          overflow-x: auto;
          width: 90%;
          margin: 0 auto;
          max-width: 1200px;
        }

        .table-div-listings {
          padding-bottom: 32px;
          overflow-x: auto;
          width: 90%;
          margin: 0 auto;
          max-width: 1200px;
          overflow-y: visible;
        }
        .table-div-ads {
          padding-bottom: 32px;
          width: 90%;
          margin: 0 auto;
          max-width: 1200px;
          }
        .table-div-alerts {
          padding-bottom: 32px;
          width: 90%;
          margin: 0 auto;
          max-width: 1200px;
          }
        .alerts-form-table {
            width: 70%; 
            max-width: 1200px;
            margin: 0 auto;
            table-layout: auto;
          }
          .alert-input-cell {
            font-size: 24px;
            width: 100%;
            max-width: 600px;  /* optional limit for large screens */
          }

          .alert-input-cell input[type="text"],
          .alert-input-cell select {
            width: 100%;
            box-sizing: border-box; /* ensures padding doesn't overflow */
            padding: 10px;
            font-size: 18px;
          }
          .myad-form-table {
            width: 70%; 
            max-width: 1000px;
            min-width: 900px;
            margin: 0 auto;
            font-size: 24px;
            table-layout: auto;
          }
          .myad-form-table td:first-child,
          .myad-form-table th:first-child {
            white-space: nowrap;        
            width: 1%; 
          }
          .myad-input-cell {
            font-size: 24px;
            width: 100%;
          }

          .myad-input-cell input[type="text"],
          .myad-input-cell3lines input[type="text"] {
            width: 100%;
            height: 6em; /* Approx. 3 lines tall */
            padding: 10px;
            font-size: 24px;
            box-sizing: border-box;
          }
          .dropdown {
            width: 100%;
            height: 3em;
            font-size: 24px;
            padding: 8px;
            box-sizing: border-box;
          }

          .table-image-wrapper {
            display: flex;
            gap: 40px;
            min-width: 1000px;
          }

        table {
          width: 90%;
        }
        .alert-table {
          width: 90%;
          margin: 1in 2in 1in 2in;
          table-layout: fixed; 
          overflow-x: auto; 
        }
        table, th, td {
          border: 1px solid #d0d0d0;
          border-collapse: collapse;
          color: #404040;
          font-size: 18px;
          font-weight: 300;
        }

        tr {
          text-align: left;
        }

        th, td {
          padding: 14px 16px;
          word-wrap: break-word; 
        }

        th {
          font-size: 24px;
          font-weight: 600;
          color: black;
        }

        .ad-id-cell {
          width: 120px; /* Use width instead of max-width with fixed layout */
          word-break: break-all;
          word-wrap: break-word;
          overflow-wrap: anywhere; /* More aggressive than break-word */
          white-space: normal;
        }

        th:nth-child(1), td:nth-child(1) { width: 15%; }
        th:nth-child(2), td:nth-child(2) { width: 10%; }
        th:nth-child(3), td:nth-child(3) { width: 8%; }
        th:nth-child(4), td:nth-child(4) { width: 8%; }
        th:nth-child(5), td:nth-child(5) { width: 8%; }
        th:nth-child(6), td:nth-child(6) { width: 12%; }
        th:nth-child(7), td:nth-child(7) { width: 10%; } 
        th:nth-child(8), td:nth-child(8) { width: 20%; }
        th:nth-child(9), td:nth-child(9) { width: 9%; } 

        .hide-button {
          padding: 5px 10px;
          cursor: pointer;
          background-color: rgb(0, 123, 255);
          border: 1px solid #ddd;
          border-radius: 4px;
        }
        td[style*="display: none;"] {
          width: 0;
          padding: 0;
          margin: 0;
          border: none;
        }
        p {
          margin: 0px;
        }
        #available-green {
          background-color: #c1ffc3;
        }
        #available-yellow {
          background-color: #fff7b2;
        }
        #available-red {
          background-color: #ffdddb;
        }

        .post-ad-button, .search-alert-button {
          padding: 8px 12px;
          border-radius: 4px;
          background-color: #f5f5f5;
          border: 1px solid #ddd;
          font-size: 24px;
          cursor: pointer;
        }
        .post-ad-button a, .search-alert-button a {
          text-decoration: none;
          font-size: 24px;
          color: inherit;
        }
        .post-ad-button:hover{
        color: blue;
        }
        .search-alert-button:hover{
        color: blue;
        }
        .post-ad-button:active, .search-alert-button:active {
        background-color: #003d80;
        font-size: 24px;
        }
        .refresh-button:hover{
        color: blue;
        }
        .refresh-button:active {
        background-color: #003d80;
        font-size: 24px;
        }
        label {
          font-size: 18px;
          font-weight: 300;
          margin-left: 6px;
          margin-bottom: 10px;
        }
        input {
          padding: 12px;
        }
        #file-input {
          padding: 0px 0px 18px;
        }
        .input-row {
          display: flex;
          flex-direction: column;
          padding-bottom: 8px;
        }
        .input-row2 {
          padding-bottom: 4px;
        }
        .input-row3 {
          padding-bottom: 16px;
        }
        .input-error {
          font-size: 18px;
          color: red;
          padding-left: 4px;
          padding-bottom: 4px;
        }
        .input-error-hidden {
          visibility: hidden;
        }
        .input-error-visible {
          visibility: visible;
        }
        #empty-row {
          text-align: center;
          vertical-align: middle;
          font-size: 18px;
          border-right-color: white;
        }
        #submit-button {
          padding: 12px;
        }
        #storage-button {
          margin-left: 16px;
        }
        .back-button {
          position: fixed;
          left: 0;
          top: 0;
          width: fit-content;
          margin-top: 56px;
          padding-bottom: 18px;
          padding-left: 16px;
        }
        #storage-label {
          margin-bottom: 16px;
        }
        
        .ship-identity {
          display: flex;
          align-items: center;
          gap: 12px;
          margin-top: 8px;
        }

        .ship-sigil {
          width: 150px;
          height: 150px;
          border-radius: 50%;
          border: 2px solid #ddd;
        }

        .ship-name {
          font-family: monospace;
          font-weight: 500;
          letter-spacing: -0.5px;
          margin: 0;
        }
        /* Form submission loading state */
        .form-submitting {
          cursor: wait !important;
          pointer-events: none;
        }

        .form-submitting * {
          cursor: wait !important;
        }

        /* Submit button loading state */
        .submit-button.loading {
          cursor: wait !important;
          opacity: 0.7;
          position: relative;
        }

        .submit-button.loading::after {
          content: '';
          position: absolute;
          top: 50%;
          left: 50%;
          width: 16px;
          height: 16px;
          margin: -8px 0 0 -8px;
          border: 2px solid transparent;
          border-top: 2px solid #fff;
          border-radius: 50%;
          animation: spin 1s linear infinite;
        }

        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .table-div-ads {
          padding-bottom: 32px;
          width: 90%;
          margin: 0 auto;
          max-width: 1200px;
          }

        .file-input.loading {
          cursor: wait !important;
        }
        /* Subscriptions page styles */
        .subscriptions-container {
          display: flex;
          justify-content: center;
          align-items: flex-start;
          margin: 20px;
          gap: 20px;
        }

        .subscription-column {
          flex: 1;
          max-width: 45%;
          display: flex;
          justify-content: center;
          padding: 20px 10px 0 10px;
        }

        .subscription-table-wrapper {
          background: white;
          padding: 20px;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          max-width: 75%;
        }

        .subscription-table {
          width: 75%;
          border-collapse: collapse;
          margin: 0 auto;
        }

        .subscription-header {
          text-align: center;
          padding: 10px;
          background: #f5f5f5;
          border: 1px solid #ddd;
        }

        .subscription-header-main {
          font-size: 1.75rem;
        }

        .subscription-header-sub {
          font-size: 1rem;
        }

        .subscription-th {
          padding: 8px;
          border: 1px solid #ddd;
          text-align: left;
          font-size: 1.75rem;
        }

        .subscription-th-wrap {
          word-wrap: break-word;
          word-break: break-word;
          max-width: 200px;
        }

        .subscription-td {
          padding: 8px;
          border: 1px solid #ddd;
        }

        .subscription-td-wrap {
          word-wrap: break-word;
          word-break: break-word;
          max-width: 200px;
        }

        .subscription-empty {
          padding: 20px;
          text-align: center;
          border: 1px solid #ddd;
          font-size: 1.25rem;
        }
        /* View Ad page styles */
        .ad-images-container {
          display: flex;
          justify-content: center;
          gap: 20px;
          margin-top: 10px;
        }

        .ad-image {
          max-width: 600px;
          max-height: 600px;
          object-fit: cover;
          border-radius: 4px;
        }

        .ad-description-wrapper {
          display: flex;
          justify-content: center;
          align-items: flex-start;
          margin: 20px;
          gap: 20px;
        }

        .ad-description-container {
          max-width: 75rem;
          min-width: 50rem;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          border-radius: 8px;
          overflow: hidden;
          background: white;
        }

        .ad-description-header {
          background: white;
          padding: 15px 20px;
          border-bottom: 1px solid #e0e0e0;
        }

        .ad-description-title {
          margin: 0;
          color: black;
          justify-content: center;
          font-size: 1.25rem;
          font-weight: 600;
          letter-spacing: 0.5px;
        }

        .ad-description-body {
          padding: 25px 20px;
          background: #ffffff;
        }

        .ad-description-text {
          font-size: 1.25rem;
          line-height: 1.6;
          color: #333;
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          text-align: justify;
          white-space: pre-wrap;
        }

        .ad-details-wrapper {
          display: flex;
          justify-content: center;
          align-items: flex-start;
          margin: 20px;
          gap: 20px;
          width: 100%;
        }

        .ad-details-column {
          flex: 1;
          max-width: 45%;
          display: flex;
          justify-content: center;
          padding: 20px 10px 0 10px;
        }

        .ad-details-table {
          width: 75%;
          border-collapse: collapse;
          margin: 0 auto;
        }

        .ad-details-cell {
          padding: 10px;
          font-size: 1.0rem;
          border: 1px solid #ddd;
          font-weight: normal;
        }
        .ad-details-label {
            width: 30%;  /* Label column narrower */
            white-space: nowrap;
          }

          .ad-details-value {
            width: 70%;  /* Value column wider */
            word-wrap: break-word;
          }

        /* Mobile landscape (740x360) and portrait (360x740) */
        @media (max-width: 768px) {
          /* Header adjustments */
            .header-wrapper {
              flex-direction: column;
              padding: 10px;
              width: 100vw;
              max-width: 100%;
              margin: 0;
              box-sizing: border-box;
              gap: 15px;
              align-items: center;
              justify-content: flex-start;
            }
          
          .header-logo {
            height: 80px;
            width: 80px;
          }
          
          .search-bar {
              width: 100%;
              max-width: 100%;
              padding: 0 10px;  /* ← Add padding here instead */
              box-sizing: border-box;
            }
            
            .search-form {
              width: 100%;
              max-width: 100%;
            }
            
            .search-form input[type="text"] {
              width: 100% !important;
              max-width: 100% !important;
              box-sizing: border-box !important;
              font-size: 16px !important;
              padding: 6px 35px 6px 10px !important;
            }
          
          .ship-box {
            width: calc(100% - 20px) !important;  /* ← Account for wrapper padding */
            max-width: 100% !important;
            padding: 8px !important;
            font-size: 10px !important;
            box-sizing: border-box !important;
            margin: 0 10px;  /* ← Add margin instead */
          }
          
          .ship-name-link {
              color: inherit;
              width: 150px;
              text-decoration: none;
              display: inline-block;
              text-align: center;
              font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', 'Source Code Pro', 'Courier New', monospace;
              font-weight: 500;
              letter-spacing: -0.5px;
            }
          
          .ship-sigil {
            width: 60px;
            height: 60px;
          }
           .main-content {
            flex-direction: column;
          }
          /* Left sidebar - convert to horizontal menu */
          .left-bar {
            width: 100%;
            min-height: auto;
            font-size: 24px;
            padding: 10px 0;
          }
          
          .left-bar ul {
            flex-direction: row;
            gap: 10px;
            font-size: 24px;
            overflow-x: auto;
            flex-wrap: wrap;
            justify-content: center;
          }
          
          .left-bar li {
            font-size: 16px;
          }
          
          .left-bar li a {
            padding: 8px 12px;
            white-space: nowrap;
          }
          
          /* Pals wrapper - stack columns vertically */
          .pals-wrapper {
            padding: 10px;
            width: 100%;
          }
          
          /* Message banner */
          .pals-wrapper > div[style*="justify-content: center"] {
            margin: 10px 0 !important;
          }
          
          .pals-wrapper > div[style*="justify-content: center"] > div {
            width: 95% !important;
            padding: 10px !important;
            font-size: 14px !important;
          }
          
          /* Stack Favorites and Avoids vertically */
          .pals-wrapper > div[style*="display: flex"][style*="gap: 20px"] {
            flex-direction: column !important;
            gap: 20px !important;
            margin: 10px 0 !important;
          }
          
          /* Table containers */
          .pals-wrapper .table-div,
          .pals-wrapper > div > div[style*="flex: 1"] {
            width: 100% !important;
            max-width: 100% !important;
            padding: 10px 5px !important;
          }
          
          /* Tables */
          .pals-wrapper table {
            width: 100% !important;
            font-size: 14px;
          }
          
          .pals-wrapper th,
          .pals-wrapper td {
            padding: 6px 4px !important;
            font-size: 14px !important;
          }
          
          .pals-wrapper th[colspan] {
            font-size: 16px !important;
            padding: 8px !important;
          }
          
          /* Form inputs in tables */
          .pals-wrapper input[type="text"] {
            font-size: 14px !important;
            padding: 4px !important;
            width: 100% !important;
          }
          
          .pals-wrapper button[type="submit"] {
            font-size: 12px !important;
            padding: 4px 8px !important;
            margin-left: 2px !important;
          }
          
          /* Add favorite/avoid forms */
          .pals-wrapper form[action*="add-"] {
            gap: 8px !important;
          }
          
          .pals-wrapper form[action*="add-"] > div {
            flex-direction: column !important;
            gap: 8px !important;
            width: 100%;
          }
          
          .pals-wrapper form[action*="add-"] input[type="text"] {
            width: 100% !important;
          }
          
          /* Radio buttons for Block option */
          .pals-wrapper input[type="radio"] {
            margin-right: 3px !important;
          }
          
          .pals-wrapper label[for*="block"] {
            font-size: 14px !important;
            margin-right: 8px !important;
          }
          
          .pals-wrapper span {
            font-size: 14px !important;
          }
          
          /* Action buttons column */
          .pals-wrapper td form {
            display: block !important;
            margin: 2px 0 !important;
          }
           th, td {
            padding: 7px 16px 7px 8px;
          }       
          /* Settings gear icon */
          .ship-box a[href*="settings"] {
            font-size: 12px !important;
            margin-left: 16px !important;
          }
           .main-content {
            flex-direction: column;
          }
           .alert-wrapper {
              width: 100%;  
              align-items: center;  
              padding: 0 10px;  
              box-sizing: border-box;
            }
            
            .table-div-alerts {
              width: 95%;
              padding-bottom: 16px;
              display: flex;
              flex-direction: column;
              align-items: center;
            }
           .alerts-form-table {
            width: 100%;
            font-size: 14px;
          }
          .alerts-form-table td,
          .alerts-form-table th {
            display: block;
            width: 100%;
            box-sizing: border-box;
          }
          
          .alerts-form-table tr {
            display: block;
            margin-bottom: 20px;
            border-bottom: 2px solid #ddd;
            padding-bottom: 10px;
          }
          
          .alerts-form-table td:first-child {
            font-weight: bold;
            padding-bottom: 5px;
          }
          
          .alert-input-cell input,
          .alert-input-cell select,
          .alert-input-cell textarea {
            width: 100% !important;
            font-size: 16px !important;
            box-sizing: border-box;
          }
          .table-wrapper {
        flex: 1;
        display: flex;
        flex-direction: column;
        justify-content: flex-start;
        padding: 20px;
        width: 95%;
        }
        }

        /* Extra small screens - portrait mode (360x740) */
        @media (max-width: 400px) {
          body {
            font-size: 14px;
          }
          
          .header-wrapper {
              flex-direction: column;
              padding: 10px;
              width: 100vw;
              max-width: 100%;
              margin: 0;
              box-sizing: border-box;
              gap: 15px;
              align-items: center;
              justify-content: flex-start;
            }
          
          .header-logo {
            height: 80px;
            width: 80px;
          }
          
          .search-bar {
              width: 100%;
              max-width: 100%;
              padding: 0 10px;  /* ← Add padding here instead */
              box-sizing: border-box;
            }
            
            .search-form {
              width: 100%;
              max-width: 100%;
            }
            
            .search-form input[type="text"] {
              width: 100% !important;
              max-width: 100% !important;
              box-sizing: border-box !important;
              font-size: 16px !important;
              padding: 6px 35px 6px 10px !important;
            }
          
          .ship-box {
            width: calc(100% - 20px) !important;  /* ← Account for wrapper padding */
            max-width: 100% !important;
            padding: 8px !important;
            font-size: 10px !important;
            box-sizing: border-box !important;
            margin: 0 10px;  /* ← Add margin instead */
          }
          
          .ship-name,
          .ship-name-link {
            font-size: 10px;
            letter-spacing: -0.3px;
          }
          
          .ship-sigil {
            width: 50px;
            height: 50px;
          }
          
          .left-bar {
            width: 100%;
            min-height: auto;
            padding: 10px 0;
          }
          
          .left-bar ul {
            flex-direction: row;
            gap: 10px;
            overflow-x: auto;
            flex-wrap: wrap;
            justify-content: center;
          }
          
          .left-bar li {
            font-size: 14px;
          }
          
          .left-bar li a {
            padding: 6px 10px;
          }
          
          /* Make tables more compact */
          .pals-wrapper th,
          .pals-wrapper td {
            padding: 4px 2px !important;
            font-size: 12px !important;
          }
          
          .pals-wrapper input[type="text"] {
            font-size: 12px !important;
            padding: 3px !important;
          }
          
          .pals-wrapper button[type="submit"] {
            font-size: 10px !important;
            padding: 3px 6px !important;
          }
          
          /* Ship names might be long - allow wrapping */
          .pals-wrapper td:first-child {
            word-break: break-all;
          }
           .main-content {
            flex-direction: column;
          }
          .alert-wrapper {
              width: 100%;  
              align-items: center;  
              padding: 0 10px;  
              box-sizing: border-box;
            }
            
            .table-div-alerts {
              width: 95%;
              padding-bottom: 16px;
              display: flex;
              flex-direction: column;
              align-items: center;
            }
           .alerts-form-table {
            width: 100%;
            font-size: 14px;
          }
          .alerts-form-table td,
          .alerts-form-table th {
            display: block;
            width: 100%;
            box-sizing: border-box;
          }
          
          .alerts-form-table tr {
            display: block;
            margin-bottom: 20px;
            border-bottom: 2px solid #ddd;
            padding-bottom: 10px;
          }
          
          .alerts-form-table td:first-child {
            font-weight: bold;
            padding-bottom: 5px;
          }
          
          .alert-input-cell input,
          .alert-input-cell select,
          .alert-input-cell textarea {
            width: 100% !important;
            font-size: 16px !important;
            box-sizing: border-box;
          }
          .table-wrapper {
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            padding: 20px;
            width: 95%;
            }
            .table-div {
          display: flex;
          flex-direction: column;
          padding-bottom: 16px;
          font-size: 18px;
          overflow-x: auto;
          margin-left: 0;
          width: fit-content;
        }
        /* Subscriptions page responsive styles */
          .subscriptions-container {
            flex-direction: column;  /* Stack vertically instead of side-by-side */
            align-items: center;
            gap: 30px;  /* Separation between boxes */
            padding: 10px;
            margin: 0;
          }
          
          .subscription-column {
            max-width: 95%;  /* Smaller width for mobile */
            width: 100%;
            padding: 0;  /* Remove extra padding */
          }
          
          .subscription-table-wrapper {
            max-width: 100%;  /* Allow full width of column */
            padding: 15px;  /* Reduce padding */
          }
          
          .subscription-table {
            width: 100%;  /* Use full available width */
            font-size: 0.75rem;  /* Smaller text */
          }
          
          .subscription-header-main {
            font-size: 1.25rem;  /* Smaller header */
          }
          
          .subscription-header-sub {
            font-size: 0.875rem;
          }
          
          .subscription-th {
            font-size: 1rem;
            padding: 6px;
          }
          
          .subscription-td {
            font-size: 0.875rem;
            padding: 6px;
          }
          
          .subscription-empty {
            font-size: 1rem;
            padding: 15px;
          }
        }
        '''
        ::
        ::
--