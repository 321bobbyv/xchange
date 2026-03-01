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
      [%link-wallet address=addr note=sigm]
      [%unlink-wallet address=addr] 
      [%verify-ad-wallet ad-id=@t =sigm]
      [%transfer-history tx-hash=@ux tx=transfer-record]
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
      body1=octs::[legnth in bytes and data]How do you send the file sizes of both images to the urbit via the form
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
+$  my-wallets  (map addr sigm)
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
      [%receive-transfer tx-hash=@ux =transfer-record]
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
+$  message-wallets  @t
+$  message-pay  @t
+$  maxpic-size  @ud
+$  maxad-timeout  @dr
+$  maxapp-size  @ud
+$  wallet-access  @b
+$  wallet-list  (list [addr sigm])
+$  addr  @ux
+$  sigm  :: Wallet signature
  $:  sign=@ux
      nickname=@t
      mesg=@t
      when=@da
      primary=?
      transfer-ok=?
  ==
+$  wallet-proof
  $:  =addr
      =ship
      signature=@t
      message=@t        :: The message that was signed
      verified=?        :: Has this been cryptographically verified?
      timestamp=@da
  ==

+$  payment-proof
  $:  tx-hash=@ux           :: Transaction hash
      from-addr=@ux         :: Buyer's wallet
      to-addr=@ux           :: Seller's wallet
      amount-eth=@t         :: Display amount (e.g., "0.5 ETH")
      amount-wei=@ud        :: Actual wei amount
      block=@ud             :: Block number
      when=@da              :: Timestamp
  ==
+$  xchange-transfer
  $:  tx-hash=@ux
      rec=transfer-record
  ==
+$  transfer-record
  $:  from-addr=(unit @ux)
      from-ship=@p
      to-addr=(unit @ux)
      to-ship=@p
      amount-eth=@t         :: Display: "0.5"
      amount-wei=@ud        :: Wei: 500000000000000000
      when=@da
      pay-memo=@t
      currency=@t
  ==
::
+$  transfer-history  (map tx-hash=@ux transfer-record)
+$  transfer-status
  $?  %pending
      %confirmed
      %failed  
  ==
+$  transfer-data
  $:  tx-hash=@ux
      rec=transfer-record
  ==
+$  pending-wallet-requests  (map request-id=@t target=@p)
+$  wallet-lookup-results  (map @ta [success=? data=(unit (list [addr sigm]))])
+$  pending-transaction
  $:  transfer=xchange-transfer
      from-ship=@p
      received-at=@da
  ==
+$  pending-transactions  (map request-id=@ta pending-transaction) 
--
