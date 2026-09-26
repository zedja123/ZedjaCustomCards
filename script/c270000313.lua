--
--Lavoisier Amazing Draco - YOUCAN
--scripted by Zedja
local s,id=GetID()
local SET_LAVOISIER=0xe03
local CARD_LAVOISIER_PROUST=270000301
local CARD_LAVOISIER_BERTHA=270000303
local CARD_LAVOISIER_ISAAC=270000304
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Lavoisier Proust" + "Lavoisier Isaac" + "Lavoisier Bertha"
	Fusion.AddProcMix(c,true,true,CARD_LAVOISIER_PROUST,CARD_LAVOISIER_ISAAC,CARD_LAVOISIER_BERTHA)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c,false)
	--You cannot Pendulum Summon, except "Lavoisier" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.pendlimit)
	c:RegisterEffect(e1)
	--When your opponent activates a card or effect in response to the activation of your "Lavoisier" card or effect: You can destroy 2 cards on the field, including a monster you control; negate the activation, and if you do, Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.pnegcon)
	e2:SetCost(s.pnegcost)
	e2:SetTarget(s.pnegtg)
	e2:SetOperation(s.pnegop)
	c:RegisterEffect(e2)
	--Cannot be destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--If this card in the Monster Zone leaves the field, place it in your Pendulum Zone
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.pzcon)
	e4:SetOperation(s.pzop)
	c:RegisterEffect(e4)
	--(Quick Effect): You can destroy 1 card you control; return cards on the field to the hand, equal to the number of "Lavoisier" monsters with different names in your face-up Extra Deck
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e5:SetCountLimit(1,{id,1})
	e5:SetCost(s.thcost)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	--When a card or effect is activated that targets a face-up card on the field (Quick Effect): You can destroy 1 card in your hand; negate the activation, and if you do, banish that card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.negcon)
	e6:SetCost(s.negcost)
	e6:SetTarget(s.negtg)
	e6:SetOperation(s.negop)
	c:RegisterEffect(e6)
	--While a Link Monster points to this card, that Link Monster gains this effect: Once per turn (Quick Effect): You can pay 3000 LP; banish 1 monster from either GY
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e7:SetCountLimit(1)
	e7:SetCost(Cost.PayLP(3000))
	e7:SetTarget(s.rmtg)
	e7:SetOperation(s.rmop)
	local e7a=Effect.CreateEffect(c)
	e7a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e7a:SetRange(LOCATION_MZONE)
	e7a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7a:SetTarget(s.granttg)
	e7a:SetLabelObject(e7)
	c:RegisterEffect(e7a)
end
s.listed_names={CARD_LAVOISIER_PROUST,CARD_LAVOISIER_BERTHA,CARD_LAVOISIER_ISAAC}
s.listed_series={SET_LAVOISIER}
function s.pendlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsSetCard(SET_LAVOISIER)
end
function s.pnegcon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and ev>1 and Duel.IsChainNegatable(ev)) then return false end
	local te,p=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler():IsSetCard(SET_LAVOISIER)
end
function s.pnegcostfilter(c,tp)
	return c:IsMonster() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.pnegrescon(sg,e,tp,mg)
	return sg:IsExists(s.pnegcostfilter,1,nil,tp)
end
function s.pnegcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsDestructable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.pnegrescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.pnegrescon,1,tp,HINTMSG_DESTROY)
	Duel.Destroy(sg,REASON_COST)
end
function s.pnegtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.pnegop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED|LOCATION_EXTRA) and c:IsFaceup()))
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetOwner()
	if Duel.CheckPendulumZones(p) and not c:IsForbidden() then
		Duel.Hint(HINT_CARD,0,id)
		Duel.MoveToField(c,p,p,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.Destroy(g,REASON_COST)
end
function s.namecount(tp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_LAVOISIER),tp,LOCATION_EXTRA,0,nil)
	return g:GetClassCount(Card.GetCode)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.namecount(tp)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,s.namecount(tp),PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=s.namecount(tp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	ct=math.min(ct,#g)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sg=g:Select(tp,ct,ct,nil)
	Duel.HintSelection(sg)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.IsChainNegatable(ev)) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(aux.FaceupFilter(Card.IsOnField),1,nil)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Destroy(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if rc:IsRelateToEffect(re) and rc:IsAbleToRemove() then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.granttg(e,c)
	return c:IsLinkMonster() and c:GetLinkedGroup():IsContains(e:GetHandler())
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
