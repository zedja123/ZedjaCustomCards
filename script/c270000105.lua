--Wiccanthrope Serwapentart
function c270000105.initial_effect(c)
	-- Special Summon from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(270000105,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,270000105)
	e1:SetCost(c270000105.spcost)
	e1:SetTarget(c270000105.sptg)
	e1:SetOperation(c270000105.spop)
	c:RegisterEffect(e1)

	-- Shuffle or add Banished card to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(270000105,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,270000105+1)
	e2:SetTarget(c270000105.tdtg)
	e2:SetOperation(c270000105.tdop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- Change all monsters' Level/Rank to 4
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(270000105,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,270000105+2)
	e4:SetCondition(c270000105.lvcon)
	e4:SetCost(c270000105.lvcost)
	e4:SetOperation(c270000105.lvop)
	c:RegisterEffect(e4)
end

function c270000105.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function c270000105.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function c270000105.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end


function c270000105.tdfilter(c, tp)
	return c:IsAbleToDeck() and c:IsAbleToHand() and c:IsFaceup()
end

function c270000105.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=c270000105.tdop(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=c270000105.thop(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return Duel.IsExistingMatchingCard(c270000105.tdfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp) and b1 or b2 end
	local op=Duel.SelectOption(tp,
		{b1,aux.Stringid(270000105,3)},
		{b2,aux.Stringid(270000105,4)})
	if op==1 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetOperation(c270000105.tdop)
	elseif op==0 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(c270000105.thop)
	end
end

function c270000105.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc:GetFirst()
	if tc then
		if tc:IsSetCard(0xf11) and tc:IsType(TYPE_SPELL) and tc:IsControler(tp) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
		end
	end
end

function c270000105.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc:GetFirst()
	if tc then
		if not tc:IsSetCard(0xf11) then
				Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

function c270000105.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

function c270000105.banfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end

function c270000105.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c270000105.banfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c270000105.banfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function c270000105.lvop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RANK)
	Duel.RegisterEffect(e2,tp)
end