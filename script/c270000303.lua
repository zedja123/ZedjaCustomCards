--
--Lavoisier Bertha
--scripted by Zedja
local s,id=GetID()
local SET_LAVOISIER=0xe03
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--You cannot Pendulum Summon, except "Lavoisier" monsters. This effect cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.pendlimit)
	c:RegisterEffect(e1)
	--You can target 1 "Lavoisier" card in your GY; destroy this card, and if you do, add that target to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.gythtg)
	e2:SetOperation(s.gythop)
	c:RegisterEffect(e2)
	--If this card is Summoned: You can destroy 1 card in your hand, and if you do, add 1 "Lavoisier" Spell/Trap from your Deck to your hand
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetCountLimit(1,{id,1})
	e3a:SetTarget(s.thtg)
	e3a:SetOperation(s.thop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3b)
	local e3c=e3a:Clone()
	e3c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3c)
	--You can shuffle any number of "Lavoisier" monsters from your face-up Extra Deck and/or GY into the Deck; Special Summon 1 "Lavoisier" Link Monster from your Extra Deck whose Link Rating equals the number of monsters shuffled
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(s.linkspcost)
	e4:SetTarget(s.linksptg)
	e4:SetOperation(s.linkspop)
	c:RegisterEffect(e4)
	--While a Link Monster points to this card, that Link Monster gains this effect: Once per turn: You can Special Summon 1 "Lavoisier" Pendulum Monster from your GY or face-up Extra Deck, but negate its effects
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.pensptg)
	e5:SetOperation(s.penspop)
	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5a:SetRange(LOCATION_MZONE)
	e5a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5a:SetTarget(s.granttg)
	e5a:SetLabelObject(e5)
	c:RegisterEffect(e5a)
end
s.listed_series={SET_LAVOISIER}
function s.pendlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsSetCard(SET_LAVOISIER)
end
function s.gythfilter(c)
	return c:IsSetCard(SET_LAVOISIER) and c:IsAbleToHand()
end
function s.gythtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gythfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gythfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.gythfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.gythop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_LAVOISIER) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.tdfilter(c)
	return c:IsSetCard(SET_LAVOISIER) and c:IsMonster() and c:IsFaceup() and c:IsAbleToDeckOrExtraAsCost()
end
function s.linkfilter(c,e,tp,ct)
	return c:IsSetCard(SET_LAVOISIER) and c:IsLinkMonster() and c:IsLink(ct)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.linkspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil)
	local nums={}
	for ct=1,#g do
		if Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ct) then
			table.insert(nums,ct)
		end
	end
	if chk==0 then return #nums>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=g:Select(tp,ct,ct,nil)
	Duel.HintSelection(rg)
	Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_COST)
	e:SetLabel(ct)
end
function s.linksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.linkspop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.granttg(e,c)
	return c:IsLinkMonster() and c:GetLinkedGroup():IsContains(e:GetHandler())
end
function s.penspfilter(c,e,tp)
	if not (c:IsSetCard(SET_LAVOISIER) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.pensptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.penspfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.penspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.penspfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		--Negate its effects
		tc:NegateEffects(e:GetHandler())
	end
	Duel.SpecialSummonComplete()
end
